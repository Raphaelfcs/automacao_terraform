output "vault_arn" {
  description = "ARN do vault."
  value       = aws_backup_vault.this.arn
}

output "plan_id" {
  description = "ID do plano."
  value       = aws_backup_plan.this.id
}

output "backup_role_arn" {
  description = "Role usada pelo AWS Backup."
  value       = aws_iam_role.backup.arn
}
