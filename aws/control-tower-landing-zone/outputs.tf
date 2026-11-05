output "landing_zone_arn" {
  description = "ARN da landing zone."
  value       = aws_controltower_landing_zone.this.arn
}

output "landing_zone_drift" {
  description = "Situação de drift da landing zone."
  value       = aws_controltower_landing_zone.this.drift_status
}

output "home_region" {
  description = "Home region (região de onde o módulo foi aplicado)."
  value       = data.aws_region.current.region
}

output "security_ou_id" {
  description = "ID da OU de segurança."
  value       = local.security_ou_id
}

output "log_archive_account_id" {
  description = "ID da conta Log Archive."
  value       = local.account_ids["log-archive"]
}

output "audit_account_id" {
  description = "ID da conta Audit."
  value       = local.account_ids["audit"]
}

output "organization_id" {
  description = "ID da organização."
  value       = data.aws_organizations_organization.this.id
}

output "manifest" {
  description = "Manifesto enviado ao Control Tower (útil para revisão em PR)."
  value       = local.manifest
}
