output "permission_set_arns" {
  description = "Mapa nome -> ARN do permission set."
  value       = { for k, p in aws_ssoadmin_permission_set.this : k => p.arn }
}

output "assignment_count" {
  description = "Quantidade de atribuições criadas."
  value       = length(aws_ssoadmin_account_assignment.this)
}
