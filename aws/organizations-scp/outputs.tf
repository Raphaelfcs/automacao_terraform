output "root_id" {
  description = "ID da raiz da organização."
  value       = local.root_id
}

output "organization_arn" {
  description = "ARN da organização (usado no compartilhamento RAM do Transit Gateway)."
  value       = data.aws_organizations_organization.this.arn
}

output "ou_ids" {
  description = "IDs das OUs por nome."
  value       = local.ou_ids
}

output "ou_arns" {
  description = "ARNs das OUs por nome."
  value = merge(
    { for k, ou in aws_organizations_organizational_unit.level1 : k => ou.arn },
    { for k, ou in aws_organizations_organizational_unit.level2 : k => ou.arn },
  )
}

output "scp_ids" {
  description = "IDs das SCPs criadas."
  value       = { for k, p in aws_organizations_policy.scp : k => p.id }
}

output "rcp_ids" {
  description = "IDs das RCPs criadas (vazio se enable_rcp = false)."
  value       = { for k, p in aws_organizations_policy.rcp : k => p.id }
}
