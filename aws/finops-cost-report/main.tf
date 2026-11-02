# Relatório diário de custos: Lambda agendada consulta o Cost Explorer, grava CSV no S3
# (com expiração) e envia resumo no SNS. Para análise detalhada use o módulo
# cur-focus-export (FOCUS em Parquet) + Athena/QuickSight.

module "bucket" {
  source = "../s3-bucket"

  bucket_name = var.bucket_name
  kms_key_arn = var.kms_key_arn
  versioning  = false
  lifecycle_rules = {
    expirar-relatorios = { prefix = "finops/", expiration_days = var.report_retention_days }
  }
  tags = var.tags
}

module "function" {
  source = "../lambda-function"

  function_name       = "${var.name_prefix}-finops-cost-report"
  description         = "Relatorio diario de custos por servico"
  source_dir          = "${path.module}/src"
  timeout             = 120
  kms_key_arn         = var.kms_key_arn
  schedule_expression = var.schedule_expression

  environment = {
    REPORT_BUCKET = module.bucket.bucket_name
    TOPIC_ARN     = var.alert_topic_arn
    COST_TAG      = var.cost_allocation_tag
    TOP_N         = tostring(var.top_n)
  }

  policy_json = data.aws_iam_policy_document.function.json
  tags        = var.tags
}
