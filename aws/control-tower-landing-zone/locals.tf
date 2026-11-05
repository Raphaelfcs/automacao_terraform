locals {
  root_id = data.aws_organizations_organization.this.roots[0].id

  tags = merge({ Gerenciado = "terraform", Camada = "landing-zone" }, var.tags)

  security_ou_id = coalesce(var.existing_security_ou_id, try(aws_organizations_organizational_unit.security[0].id, null))

  shared_accounts = {
    log-archive = var.log_archive_account
    audit       = var.audit_account
  }

  accounts_to_create = { for k, v in local.shared_accounts : k => v if v.id == null }

  account_ids = {
    for k, v in local.shared_accounts : k => coalesce(v.id, try(aws_organizations_account.shared[k].id, null))
  }

  kms = { for k, v in { kmsKeyArn = var.kms_key_arn } : k => v if v != null }

  retention = {
    loggingBucket       = { retentionDays = var.log_retention_days }
    accessLoggingBucket = { retentionDays = var.access_log_retention_days }
  }

  # Manifesto 4.0: toda integração exige o flag "enabled" explícito, sem valores padrão.
  manifest = {
    governedRegions  = var.governed_regions
    accessManagement = { enabled = var.enable_identity_center }
    securityRoles = {
      enabled   = var.enable_security_roles
      accountId = local.account_ids["audit"]
    }
    centralizedLogging = {
      enabled        = var.enable_centralized_logging
      accountId      = local.account_ids["log-archive"]
      configurations = merge(local.retention, local.kms)
    }
    config = {
      enabled        = var.enable_config
      accountId      = local.account_ids["audit"]
      configurations = merge(local.retention, local.kms)
    }
    # Os dois ramos têm formatos diferentes; passar por JSON mantém o tipo do conditional estável.
    backup = jsondecode(var.backup == null ? jsonencode({ enabled = false }) : jsonencode({
      enabled = true
      configurations = {
        backupAdmin   = { accountId = try(var.backup.admin_account_id, null) }
        centralBackup = { accountId = try(var.backup.central_account_id, null) }
        kmsKeyArn     = try(var.backup.kms_key_arn, null)
      }
    }))
  }
}
