output "cluster_id" {
  description = "Identificador do cluster."
  value       = aws_rds_cluster.this.id
}

output "cluster_arn" {
  description = "ARN do cluster."
  value       = aws_rds_cluster.this.arn
}

output "writer_endpoint" {
  description = "Endpoint de escrita."
  value       = aws_rds_cluster.this.endpoint
}

output "reader_endpoint" {
  description = "Endpoint de leitura (balanceia entre réplicas)."
  value       = aws_rds_cluster.this.reader_endpoint
}

output "port" {
  description = "Porta do cluster."
  value       = aws_rds_cluster.this.port
}

output "master_user_secret_arn" {
  description = "Secret com a credencial master (gerenciado pela AWS)."
  value       = try(aws_rds_cluster.this.master_user_secret[0].secret_arn, null)
}

output "security_group_id" {
  description = "Security group do cluster."
  value       = aws_security_group.this.id
}
