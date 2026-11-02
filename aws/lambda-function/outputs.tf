output "function_name" {
  description = "Nome da função."
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN da função."
  value       = aws_lambda_function.this.arn
}

output "role_name" {
  description = "Role de execução (para anexar políticas adicionais)."
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN da role de execução."
  value       = aws_iam_role.this.arn
}

output "log_group_name" {
  description = "Log group da função."
  value       = aws_cloudwatch_log_group.this.name
}
