output "primary_endpoint_address" {
  description = "Endpoint de escrita."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Endpoint de leitura (balanceia entre réplicas)."
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Porta do cache."
  value       = aws_elasticache_replication_group.this.port
}

output "security_group_id" {
  description = "Security group do cluster."
  value       = aws_security_group.this.id
}
