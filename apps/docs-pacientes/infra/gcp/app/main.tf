data "terraform_remote_state" "gcp_base" {
  backend = "gcs"
  config = {
    bucket = var.estado_gcp_bucket
    prefix = "docs-pacientes/${var.ambiente}/gcp/base"
  }
}

data "terraform_remote_state" "aws_base" {
  backend = "s3"
  config = {
    bucket = var.estado_aws_bucket
    key    = "docs-pacientes/${var.ambiente}/aws/base/terraform.tfstate"
    region = "sa-east-1"
  }
}

data "terraform_remote_state" "aws_identidade" {
  backend = "s3"
  config = {
    bucket = var.estado_aws_bucket
    key    = "docs-pacientes/${var.ambiente}/aws/identidade/terraform.tfstate"
    region = "sa-east-1"
  }
}

data "terraform_remote_state" "aws_app" {
  backend = "s3"
  config = {
    bucket = var.estado_aws_bucket
    key    = "docs-pacientes/${var.ambiente}/aws/app/terraform.tfstate"
    region = "sa-east-1"
  }
}

# Aplicação no Google Cloud: a mesma imagem em dois serviços Cloud Run (API pública só pelo Load
# Balancer; eventos privado, chamado pelo Eventarc), o front num bucket com CDN e a borda global
# com Cloud Armor. Aplicar depois de aws/app (usa a role federada criada lá).

module "api" {
  source                = "../../../../../gcp/cloud-run-service"
  project_id            = var.projeto_gcp
  name                  = "${local.nome}-api"
  region                = var.regiao_gcp
  image                 = var.imagem
  service_account_email = local.base.conta_api
  ingress               = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  invoker_members       = ["allUsers"] # só alcançável pelo LB (ingress); autenticação é o JWT do Cognito
  create_serverless_neg = true
  max_instances         = var.max_instancias_api
  env                   = merge(local.ambiente_run, { MODO = "api", GCP_CONTA_ASSINATURA = local.base.conta_api })
  deletion_protection   = var.ambiente == "prd"
  labels                = local.labels
}

module "eventos" {
  source                = "../../../../../gcp/cloud-run-service"
  project_id            = var.projeto_gcp
  name                  = "${local.nome}-eventos"
  region                = var.regiao_gcp
  image                 = var.imagem
  service_account_email = local.base.conta_eventos
  ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  max_instances         = 10
  memory                = "1Gi"
  env                   = merge(local.ambiente_run, { MODO = "eventos", GCP_CONTA_ASSINATURA = local.base.conta_eventos })
  deletion_protection   = var.ambiente == "prd"
  labels                = local.labels
}

module "gatilhos" {
  source                  = "../../../../../gcp/eventarc-trigger"
  project_id              = var.projeto_gcp
  region                  = var.regiao_gcp
  cloud_run_service       = module.eventos.name
  service_account_id      = "${local.nome}-eventarc"
  grant_storage_publisher = true
  triggers = {
    "${local.nome}-objeto-criado" = {
      filters = { type = "google.cloud.storage.object.v1.finalized", bucket = local.base.bucket_documentos }
      path    = "/eventos/gcs"
    }
    "${local.nome}-item-gravado" = {
      filters       = { type = "google.cloud.firestore.document.v1.written", database = local.base.firestore_banco }
      path_patterns = { document = "itens/{id}" }
      path          = "/eventos/firestore"
    }
  }
  labels = local.labels
}

module "web" {
  source                = "../../../../../gcp/static-site"
  project_id            = var.projeto_gcp
  environment           = var.ambiente
  app_name              = "docs-web"
  location              = var.regiao_gcp
  public_access_enabled = true # só a casca do app (HTML/JS/CSS); nenhum dado de paciente
  site_source_dir       = "${path.module}/../../../web"
  assets_cache_control  = "no-cache"
  extra_objects = {
    "config.json" = jsonencode({ cognito = local.ids.config_web, nuvem = "gcp" })
  }
  labels = local.labels
}

module "borda" {
  source                  = "../../../../../gcp/serverless-edge"
  project_id              = var.projeto_gcp
  name                    = local.nome
  domain                  = var.dominio_app
  serverless_neg_id       = module.api.neg_id
  web_bucket_name         = module.web.site_bucket_name
  allowed_countries       = var.paises_permitidos
  geo_exempt_paths        = ["/api/health"] # health check do Route 53 sai dos EUA
  content_security_policy = local.csp
}

output "lb_ip" {
  value = module.borda.ip_address
}

output "registro_autorizacao_dns" {
  value = module.borda.dns_authorization_record
}
