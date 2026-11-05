# Exemplo "landing-zone" do módulo aws/control-tower-landing-zone: Control Tower 4.0 enxuto para
# MVP (Backup desligado, retenção curta de access logs). Roda na conta de gerenciamento.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "landing_zone" {
  source = "../.."

  governed_regions = ["sa-east-1", "us-east-1"]

  log_archive_account = {
    name  = "demo-log-archive"
    email = "aws+demo-log-archive@example.com"
  }
  audit_account = {
    name  = "demo-security-audit"
    email = "aws+demo-security-audit@example.com"
  }

  log_retention_days        = 365
  access_log_retention_days = 30
  tags                      = local.tags
}

output "log_archive_account_id" {
  value = module.landing_zone.log_archive_account_id
}

output "audit_account_id" {
  value = module.landing_zone.audit_account_id
}
