output "fqdns" {
  description = "Nomes criados por chave lógica."
  value       = { for k, r in aws_route53_record.this : k => r.fqdn }
}
