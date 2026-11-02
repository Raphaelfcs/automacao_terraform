# AWS Backup nativo no lugar das antigas Lambdas de AMI diária: vault cifrado com KMS
# (Vault Lock opcional para imutabilidade/ransomware), plano com regras diária/semanal/
# mensal, cópia para outra região/conta (DR) e seleção por tag. Cobre EC2, EBS, RDS,
# Aurora, DynamoDB, EFS e S3 com retenção e ciclo de vida centralizados.

resource "aws_backup_vault" "this" {
  name          = "${var.name_prefix}-vault"
  kms_key_arn   = var.kms_key_arn
  force_destroy = false
  tags          = var.tags
}

resource "aws_backup_vault_lock_configuration" "this" {
  count = var.vault_lock == null ? 0 : 1

  backup_vault_name   = aws_backup_vault.this.name
  min_retention_days  = var.vault_lock.min_retention_days
  max_retention_days  = var.vault_lock.max_retention_days
  changeable_for_days = var.vault_lock.changeable_for_days
}

resource "aws_backup_plan" "this" {
  name = "${var.name_prefix}-plan"

  dynamic "rule" {
    for_each = var.rules
    content {
      rule_name                = rule.key
      target_vault_name        = aws_backup_vault.this.name
      schedule                 = rule.value.schedule
      schedule_expression_timezone = var.timezone
      start_window             = 60
      completion_window        = 360
      enable_continuous_backup = rule.value.continuous

      lifecycle {
        cold_storage_after = rule.value.cold_storage_after_days
        delete_after       = rule.value.delete_after_days
      }

      dynamic "copy_action" {
        for_each = var.copy_destination_vault_arn == null ? [] : [var.copy_destination_vault_arn]
        content {
          destination_vault_arn = copy_action.value
          lifecycle {
            delete_after = rule.value.delete_after_days
          }
        }
      }

      recovery_point_tags = merge(var.tags, { RegraBackup = rule.key })
    }
  }

  tags = var.tags
}

resource "aws_backup_selection" "by_tag" {
  name         = "${var.name_prefix}-por-tag"
  plan_id      = aws_backup_plan.this.id
  iam_role_arn = aws_iam_role.backup.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.selection_tag_key
    value = var.selection_tag_value
  }
}

resource "aws_backup_vault_notifications" "this" {
  count = var.notification_topic_arn == null ? 0 : 1

  backup_vault_name   = aws_backup_vault.this.name
  sns_topic_arn       = var.notification_topic_arn
  backup_vault_events = ["BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED", "COPY_JOB_FAILED", "BACKUP_JOB_EXPIRED"]
}
