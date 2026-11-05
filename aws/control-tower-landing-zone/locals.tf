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

  kms = var.kms_key_arn == null ? {} : { kmsKeyArn = var.kms_key_arn }

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
    backup = var.backup == null ? { enabled = false } : {
      enabled = true
      configurations = {
        backupAdmin   = { accountId = var.backup.admin_account_id }
        centralBackup = { accountId = var.backup.central_account_id }
        kmsKeyArn     = var.backup.kms_key_arn
      }
    }
  }
}
