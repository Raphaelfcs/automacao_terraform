output "bootstrap_brokers_sasl_iam" {
  description = "Bootstrap servers SASL/IAM — como os clientes se conectam."
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_iam
}

output "cluster_arn" {
  description = "ARN do cluster MSK."
  value       = aws_msk_cluster.this.arn
}

output "security_group_id" {
  description = "Security group do cluster."
  value       = aws_security_group.this.id
}

output "client_policy_arn" {
  description = "Política IAM para anexar às roles dos produtores/consumidores."
  value       = aws_iam_policy.client.arn
}
