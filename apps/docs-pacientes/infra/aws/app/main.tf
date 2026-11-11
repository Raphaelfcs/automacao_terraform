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

data "terraform_remote_state" "gcp_base" {
  backend = "gcs"
  config = {
    bucket = var.estado_gcp_bucket
    prefix = "docs-pacientes/${var.ambiente}/gcp/base"
  }
}

# Aplicação na AWS: três Lambdas (API, validação do PDF ao chegar, replicação para o GCP), API HTTP,
# front na CloudFront com WAF e a role que o Cloud Run do GCP assume para gravar aqui.

module "fn_api" {
  source             = "../../../../../aws/lambda-function"
  function_name      = "${local.nome}-api"
  description        = "API de documentos de pacientes"
  source_dir         = local.codigo_lambda
  handler            = "docs_pacientes.entry.aws_lambda.api"
  memory_size        = 512
  timeout            = 15
  environment        = local.ambiente_lambda
  policy_json        = local.politica_api
  attach_policy_json = true
  tracing            = true
  kms_key_arn        = local.base.kms_arn
  log_retention_days = 365
  tags               = local.tags
}

module "fn_eventos" {
  source             = "../../../../../aws/lambda-function"
  function_name      = "${local.nome}-eventos"
  description        = "Valida o PDF quando ele chega ao bucket"
  source_dir         = local.codigo_lambda
  handler            = "docs_pacientes.entry.aws_lambda.objeto_criado"
  memory_size        = 1024
  timeout            = 60
  environment        = local.ambiente_lambda
  policy_json        = local.politica_eventos
  attach_policy_json = true
  tracing            = true
  kms_key_arn        = local.base.kms_arn
  log_retention_days = 365
  event_patterns = {
    objeto-criado = {
      source        = ["aws.s3"]
      "detail-type" = ["Object Created"]
      detail        = { bucket = { name = [local.base.bucket_documentos] }, object = { key = [{ prefix = "clinicas/" }] } }
    }
  }
  tags = local.tags
}

module "fn_replicador" {
  source                         = "../../../../../aws/lambda-function"
  function_name                  = "${local.nome}-replicador"
  description                    = "Replica itens e PDFs para o Google Cloud"
  source_dir                     = local.codigo_lambda
  handler                        = "docs_pacientes.entry.aws_lambda.stream"
  memory_size                    = 1024
  timeout                        = 120
  environment                    = local.ambiente_lambda
  policy_json                    = local.politica_replicador
  attach_policy_json             = true
  tracing                        = true
  kms_key_arn                    = local.base.kms_arn
  log_retention_days             = 365
  dynamodb_stream_arn            = local.base.tabela_stream_arn
  stream_failure_destination_arn = local.base.fila_falhas_arn
  tags                           = local.tags
}

module "api" {
  source                 = "../../../../../aws/api-gateway-lambda"
  name                   = "${local.nome}-api"
  description            = "API de documentos (atrás da CloudFront em /api/*)"
  lambda_function_name   = module.fn_api.function_name
  lambda_invoke_arn      = module.fn_api.invoke_arn
  throttling_burst_limit = 100
  throttling_rate_limit  = 50
  kms_key_arn            = local.base.kms_arn
  log_retention_days     = 365
  tags                   = local.tags
}

module "certificado" {
  source      = "../../../../../aws/acm-certificate"
  providers   = { aws = aws.us_east_1 }
  domain_name = var.dominio_app
  zone_id     = var.zona_dns_id
  tags        = local.tags
}

module "waf" {
  source              = "../../../../../aws/waf-web-acl"
  providers           = { aws = aws.us_east_1 }
  name                = "${local.nome}-borda"
  allowed_countries   = var.paises_permitidos
  geo_exempt_paths    = ["/api/health"] # health check do Route 53 sai dos EUA
  rate_limit_per_5min = 1000
  tags                = local.tags
}

module "web" {
  source                  = "../../../../../aws/cloudfront-spa"
  name_prefix             = local.nome
  app_name                = "web"
  dist_path               = "${path.module}/../../../web"
  aliases                 = [var.dominio_app]
  acm_certificate_arn     = module.certificado.certificate_arn
  web_acl_id              = module.waf.arn
  content_security_policy = local.csp
  api_origin_domain       = replace(replace(module.api.invoke_url, "https://", ""), "/", "")
  api_path_patterns       = ["/api/*"]
  assets_cache_control    = "no-cache"
  extra_objects = {
    "config.json" = jsonencode({ cognito = local.ids.config_web, nuvem = "aws" })
  }
  tags = local.tags
}

module "role_gcp" {
  source                     = "../../../../../aws/iam-role-gcp-federation"
  role_name                  = "${local.nome}-gcp"
  google_service_account_ids = local.gcp.ids_contas_cloud_run
  policy_json                = local.politica_gcp
  tags                       = local.tags
}

output "cloudfront_dominio" {
  value = module.web.domain_name
}

output "role_gcp_arn" {
  value = module.role_gcp.role_arn
}

output "api_url" {
  value = module.api.invoke_url
}
