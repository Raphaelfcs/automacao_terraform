output "fqdn" {
  description = "Nome delegado."
  value       = aws_route53_record.delegation.fqdn
}
