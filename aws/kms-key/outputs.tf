output "key_arn" {
  description = "ARN da chave KMS."
  value       = aws_kms_key.this.arn
}

output "key_id" {
  description = "ID da chave KMS."
  value       = aws_kms_key.this.key_id
}

output "alias_name" {
  description = "Nome do alias (alias/<name_prefix>)."
  value       = aws_kms_alias.this.name
}
