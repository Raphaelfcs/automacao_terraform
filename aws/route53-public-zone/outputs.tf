output "zone_id" {
  description = "ID da zona hospedada."
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "Domínio da zona."
  value       = aws_route53_zone.this.name
}

output "name_servers" {
  description = "Servidores de nome: cadastre no registrador (zona raiz) ou delegue na zona pai (subdomínio)."
  value       = aws_route53_zone.this.name_servers
}

output "certificate_arn" {
  description = "ARN do certificado curinga (null se não emitido)."
  value       = try(aws_acm_certificate.wildcard[0].arn, null)
}
