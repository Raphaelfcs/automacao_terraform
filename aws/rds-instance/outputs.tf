output "endpoint" {
  description = "Endpoint host:porta da instância."
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "Hostname da instância."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "Porta da instância."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Banco inicial."
  value       = aws_db_instance.this.db_name
}

output "master_user_secret_arn" {
  description = "ARN do secret gerenciado pela AWS com a credencial master. Aplicações leem daqui."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  description = "Security group da instância (use para liberar novos clientes)."
  value       = aws_security_group.this.id
}
