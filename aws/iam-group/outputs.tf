output "group_name" {
  description = "Nome do grupo."
  value       = aws_iam_group.this.name
}

output "group_arn" {
  description = "ARN do grupo."
  value       = aws_iam_group.this.arn
}

output "custom_policy_arns" {
  description = "Mapa nome -> ARN das políticas customizadas."
  value       = { for k, p in aws_iam_policy.custom : k => p.arn }
}
