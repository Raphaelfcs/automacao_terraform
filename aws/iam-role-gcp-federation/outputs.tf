output "role_arn" {
  description = "ARN da role (vai na configuração do workload no GCP)."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Nome da role."
  value       = aws_iam_role.this.name
}
