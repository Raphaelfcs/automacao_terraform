output "name" {
  description = "Nome da tabela."
  value       = aws_dynamodb_table.this.name
}

output "arn" {
  description = "ARN da tabela."
  value       = aws_dynamodb_table.this.arn
}

output "stream_arn" {
  description = "ARN do stream (null sem stream)."
  value       = aws_dynamodb_table.this.stream_arn
}

output "index_arns" {
  description = "ARNs dos índices globais (para políticas IAM)."
  value       = [for n in keys(var.global_secondary_indexes) : "${aws_dynamodb_table.this.arn}/index/${n}"]
}
