# Baseline de segurança da organização a partir da conta Security (administradora
# delegada): GuardDuty, Security Hub, Inspector, Macie e Access Analyzer para todas as
# contas, alertas de achados por EventBridge -> SNS e, opcionalmente, o bucket imutável
# (Object Lock) da conta Log Archive.
# Pré-requisito: a conta de gerenciamento delegou a administração destes serviços.
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# ----------------------------------------------------------------------------- detecção
resource "aws_guardduty_detector" "this" {
  count                        = var.enable_detection ? 1 : 0
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  tags                         = local.tags
}

resource "aws_guardduty_organization_configuration" "this" {
  count                            = var.enable_detection ? 1 : 0
  detector_id                      = aws_guardduty_detector.this[0].id
  auto_enable_organization_members = "ALL"
}

resource "aws_securityhub_account" "this" {
  count                    = var.enable_detection ? 1 : 0
  enable_default_standards = false
  auto_enable_controls     = true
}

resource "aws_securityhub_organization_configuration" "this" {
  count                 = var.enable_detection ? 1 : 0
  auto_enable           = true
  auto_enable_standards = "NONE"
  depends_on            = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "this" {
  for_each      = var.enable_detection ? toset(local.standards_arns) : toset([])
  standards_arn = each.value
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_finding_aggregator" "this" {
  count        = var.enable_detection ? 1 : 0
  linking_mode = "ALL_REGIONS"
  depends_on   = [aws_securityhub_account.this]
}

resource "aws_inspector2_organization_configuration" "this" {
  count = var.enable_detection && var.enable_inspector ? 1 : 0
  auto_enable {
    ec2         = true
    ecr         = true
    lambda      = true
    lambda_code = true
  }
}

resource "aws_macie2_account" "this" {
  count                        = var.enable_detection && var.enable_macie ? 1 : 0
  finding_publishing_frequency = "ONE_HOUR"
  status                       = "ENABLED"
}

resource "aws_macie2_organization_configuration" "this" {
  count       = length(aws_macie2_account.this)
  auto_enable = true
  depends_on  = [aws_macie2_account.this]
}

resource "aws_accessanalyzer_analyzer" "org" {
  count         = var.enable_detection ? 1 : 0
  analyzer_name = "${local.name}-organizacao"
  type          = "ORGANIZATION"
  tags          = local.tags
}

# ----------------------------------------------------------------------------- alertas
resource "aws_kms_key" "alerts" {
  count               = var.enable_detection ? 1 : 0
  description         = "${local.name} - tópico de alertas de segurança"
  enable_key_rotation = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AdminDaConta"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "EventBridgePublica"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = ["kms:Decrypt", "kms:GenerateDataKey*"]
        Resource  = "*"
      },
    ]
  })
  tags = local.tags
}

resource "aws_sns_topic" "alerts" {
  count             = var.enable_detection ? 1 : 0
  name              = "${local.name}-alertas"
  kms_master_key_id = aws_kms_key.alerts[0].arn
  tags              = local.tags
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = var.enable_detection ? toset(var.alert_emails) : toset([])
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_event_rule" "alerts" {
  for_each      = { for k, v in local.alert_patterns : k => v if var.enable_detection }
  name          = "${local.name}-${each.key}-critico"
  description   = "Achados críticos de ${each.key} de qualquer conta da organização"
  event_pattern = jsonencode(each.value)
  tags          = local.tags
}

resource "aws_cloudwatch_event_target" "alerts" {
  for_each = aws_cloudwatch_event_rule.alerts
  rule     = each.value.name
  arn      = aws_sns_topic.alerts[0].arn
}

# ----------------------------------------------------------------------------- Log Archive (opcional)
resource "aws_s3_bucket" "logs" {
  count               = var.create_log_archive_bucket ? 1 : 0
  bucket_prefix       = "${local.name}-log-archive-"
  object_lock_enabled = true
  tags                = local.tags
}

resource "aws_s3_bucket_versioning" "logs" {
  count  = length(aws_s3_bucket.logs)
  bucket = aws_s3_bucket.logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "logs" {
  count  = length(aws_s3_bucket.logs)
  bucket = aws_s3_bucket.logs[0].id
  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = var.log_retention_days
    }
  }
  depends_on = [aws_s3_bucket_versioning.logs]
}

resource "aws_s3_bucket_public_access_block" "logs" {
  count                   = length(aws_s3_bucket.logs)
  bucket                  = aws_s3_bucket.logs[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count  = length(aws_s3_bucket.logs)
  bucket = aws_s3_bucket.logs[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# logs consultados raramente: Intelligent-Tiering volta ao acesso frequente sozinho quando lidos
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count  = length(aws_s3_bucket.logs)
  bucket = aws_s3_bucket.logs[0].id
  rule {
    id     = "intelligent-tiering"
    status = "Enabled"
    filter {}
    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
  }
  depends_on = [aws_s3_bucket_versioning.logs]
}
