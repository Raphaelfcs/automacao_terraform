# Inventário IAM semanal em JSON no S3 (versionado, cifrado, com retenção): usuários,
# grupos, roles e políticas locais com seus documentos.

module "bucket" {
  source = "../s3-bucket"

  bucket_name = var.bucket_name
  kms_key_arn = var.kms_key_arn
  lifecycle_rules = {
    expirar-inventario = { expiration_days = var.retention_days, noncurrent_expiration_days = 30 }
  }
  tags = var.tags
}

module "function" {
  source = "../lambda-function"

  function_name       = "${var.name_prefix}-iam-inventory"
  description         = "Exporta inventario IAM para o S3"
  source_dir          = "${path.module}/src"
  timeout             = 300
  memory_size         = 512
  kms_key_arn         = var.kms_key_arn
  schedule_expression = var.schedule_expression

  environment = {
    BUCKET = module.bucket.bucket_name
  }

  policy_json = data.aws_iam_policy_document.function.json
  tags        = var.tags
}
