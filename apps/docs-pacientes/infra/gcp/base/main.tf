# Base de dados no Google Cloud: chave, Firestore, bucket dos PDFs, contas de serviço do Cloud Run
# (criadas aqui para a AWS poder confiar nelas antes de o serviço existir) e a federação que deixa
# as Lambdas da AWS gravarem aqui sem chave. Primeiro root a aplicar.

data "google_project" "this" {
  project_id = var.projeto_gcp
}

module "kms" {
  source        = "../../../../../gcp/kms-key"
  project_id    = var.projeto_gcp
  location      = var.regiao_gcp
  key_ring_name = local.nome
  key_name      = "dados"
  encrypter_decrypter_members = [
    "serviceAccount:service-${data.google_project.this.number}@gs-project-accounts.iam.gserviceaccount.com",
    "serviceAccount:service-${data.google_project.this.number}@gcp-sa-firestore.iam.gserviceaccount.com",
  ]
  labels = local.labels
}

module "firestore" {
  source            = "../../../../../gcp/firestore-database"
  project_id        = var.projeto_gcp
  location          = var.regiao_gcp
  kms_key_id        = module.kms.key_id
  delete_protection = var.protecao_exclusao
  composite_indexes = {
    clinica   = { collection = "itens", fields = [{ path = "pk" }, { path = "sk" }] }
    auditoria = { collection = "itens", fields = [{ path = "pk" }, { path = "sk", order = "DESCENDING" }] }
    paciente  = { collection = "itens", fields = [{ path = "paciente_sub" }, { path = "sk" }] }
  }
}

module "contas" {
  source     = "../../../../../gcp/service-accounts"
  project_id = var.projeto_gcp
  accounts = {
    "${local.nome}-api"     = { display_name = "Docs API (Cloud Run)", project_roles = ["roles/datastore.user"], self_sign = true }
    "${local.nome}-eventos" = { display_name = "Docs eventos (Cloud Run)", project_roles = ["roles/datastore.user"], self_sign = true }
  }
}

# Lambdas da AWS (nomes previsíveis: <função>-role) gravam no Firestore e no bucket.
module "federacao_aws" {
  source             = "../../../../../gcp/workload-identity-aws"
  project_id         = var.projeto_gcp
  pool_id            = "${local.nome}-aws"
  aws_account_id     = var.conta_aws
  aws_role_names     = ["${local.nome}-api-role", "${local.nome}-eventos-role", "${local.nome}-replicador-role"]
  service_account_id = "${local.nome}-aws"
  project_roles      = ["roles/datastore.user"]
  allow_self_sign    = true
}

module "documentos" {
  source          = "../../../../../gcp/gcs-bucket"
  project_id      = var.projeto_gcp
  name            = "${var.projeto_gcp}-documentos"
  location        = var.regiao_gcp
  kms_key_id      = module.kms.key_id
  retention_days  = var.retencao_dias
  lock_retention  = var.travar_retencao
  cold_after_days = 30
  cors_origins    = ["https://${var.dominio_app}"]
  iam_bindings = [
    { role = "roles/storage.objectUser", member = "serviceAccount:${module.contas.emails["${local.nome}-api"]}" },
    { role = "roles/storage.objectUser", member = "serviceAccount:${module.contas.emails["${local.nome}-eventos"]}" },
    { role = "roles/storage.objectUser", member = "serviceAccount:${module.federacao_aws.service_account_email}" },
  ]
  labels = local.labels
}

output "projeto" {
  value = var.projeto_gcp
}

output "firestore_banco" {
  value = module.firestore.name
}

output "bucket_documentos" {
  value = module.documentos.name
}

output "conta_api" {
  value = module.contas.emails["${local.nome}-api"]
}

output "conta_eventos" {
  value = module.contas.emails["${local.nome}-eventos"]
}

output "ids_contas_cloud_run" {
  description = "IDs únicos das contas do Cloud Run (trust policy da role federada na AWS)."
  value       = [module.contas.unique_ids["${local.nome}-api"], module.contas.unique_ids["${local.nome}-eventos"]]
}

output "federacao_config" {
  description = "Config external_account usada pelas Lambdas (sem segredo)."
  value       = module.federacao_aws.credential_config
}

output "conta_federada" {
  value = module.federacao_aws.service_account_email
}
