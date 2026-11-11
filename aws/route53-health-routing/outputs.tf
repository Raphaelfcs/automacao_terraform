output "health_check_ids" {
  description = "IDs dos health checks por endpoint."
  value       = { for k, h in aws_route53_health_check.this : k => h.id }
}

output "fqdn" {
  description = "Nome publicado."
  value       = var.record_name
}
