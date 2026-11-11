# Base de dados na AWS: chave KMS, tabela única (com stream para replicar ao GCP), bucket dos PDFs
# (CORS para upload direto do navegador, eventos no EventBridge e Object Lock), fila de falhas da
# replicação e tópico de alarmes. Aplicar depois de gcp/base.

module "kms" {
  source                  = "../../../../../aws/kms-key"
  name_prefix             = local.nome
  description             = "Docs de pacientes (${var.ambiente}): tabela, PDFs, logs e filas"
  rotation_period_in_days = 90
  allow_cloudwatch_logs   = true
  service_principals      = ["sns.amazonaws.com", "events.amazonaws.com"]
  tags                    = local.tags
}

module "tabela" {
  source              = "../../../../../aws/dynamodb-table"
  name                = "${local.nome}-itens"
  kms_key_arn         = module.kms.key_arn
  stream_view_type    = "NEW_AND_OLD_IMAGES"
  deletion_protection = var.protecao_exclusao
  global_secondary_indexes = {
    por_paciente = { hash_key = "paciente_sub", range_key = "sk" }
  }
  tags = local.tags
}

module "documentos" {
  source                    = "../../../../../aws/s3-bucket"
  bucket_name               = "${local.nome}-documentos-${var.conta_aws}"
  kms_key_arn               = module.kms.key_arn
  versioning                = true
  cors_allowed_origins      = ["https://${var.dominio_app}"]
  eventbridge_notifications = true
  object_lock               = var.object_lock
  lifecycle_rules = {
    frio-depois-de-30-dias = { transition_days = 30, transition_storage_class = "STANDARD_IA" }
  }
  tags = local.tags
}

module "filas" {
  source      = "../../../../../aws/sqs-queue"
  name_prefix = local.nome
  queues      = ["replicacao-falhas"]
  kms_key_arn = module.kms.key_arn
  tags        = local.tags
}

module "alertas" {
  source             = "../../../../../aws/sns-topic"
  name_prefix        = local.nome
  topic_names        = ["alertas"]
  kms_key_arn        = module.kms.key_arn
  publisher_services = ["cloudwatch.amazonaws.com", "events.amazonaws.com"]
  subscriptions = {
    alertas = [for e in var.emails_alerta : { protocol = "email", endpoint = e }]
  }
  tags = local.tags
}

output "kms_arn" {
  value = module.kms.key_arn
}

output "tabela_nome" {
  value = module.tabela.name
}

output "tabela_arn" {
  value = module.tabela.arn
}

output "tabela_stream_arn" {
  value = module.tabela.stream_arn
}

output "bucket_documentos" {
  value = module.documentos.bucket_name
}

output "bucket_documentos_arn" {
  value = module.documentos.bucket_arn
}

output "fila_falhas_arn" {
  value = module.filas.queue_arns["replicacao-falhas"]
}

output "topico_alertas_arn" {
  value = module.alertas.topic_arns["alertas"]
}
