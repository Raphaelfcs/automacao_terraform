# Pipeline de extração de documentos (OCR inteligente): upload no bucket de entrada ->
# EventBridge (notificação S3) -> Lambda -> Textract (FORMS/TABLES) -> JSON no bucket de
# saída. Redesenho da Lambda lambda_textract_s3 com buckets cifrados e permissões mínimas.

module "input" {
  source = "../s3-bucket"

  bucket_name = "${var.name_prefix}-documentos-entrada"
  kms_key_arn = var.kms_key_arn
  versioning  = false
  lifecycle_rules = {
    expirar-entrada = { expiration_days = var.input_retention_days }
  }
  tags = var.tags
}

module "output" {
  source = "../s3-bucket"

  bucket_name = "${var.name_prefix}-documentos-extraidos"
  kms_key_arn = var.kms_key_arn
  tags        = var.tags
}

# Notificações do bucket via EventBridge (permite filtrar por prefixo/sufixo na regra).
resource "aws_s3_bucket_notification" "input" {
  bucket      = module.input.bucket_name
  eventbridge = true
}

module "function" {
  source = "../lambda-function"

  function_name = "${var.name_prefix}-textract"
  description   = "Extrai formularios e tabelas com Textract"
  source_dir    = "${path.module}/src"
  timeout       = 600
  memory_size   = 512
  kms_key_arn   = var.kms_key_arn

  environment = {
    OUTPUT_BUCKET = module.output.bucket_name
    FEATURES      = join(",", var.features)
  }

  policy_json = data.aws_iam_policy_document.function.json

  event_patterns = {
    upload = {
      source        = ["aws.s3"]
      "detail-type" = ["Object Created"]
      detail = {
        bucket = { name = [module.input.bucket_name] }
        object = { key = [for s in var.accepted_suffixes : { suffix = s }] }
      }
    }
  }

  tags = var.tags
}
