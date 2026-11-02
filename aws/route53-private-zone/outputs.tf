output "zone_id" {
  description = "ID da zona privada."
  value       = aws_route53_zone.this.zone_id
}

output "record_fqdns" {
  description = "FQDN de cada registro criado."
  value = merge(
    { for k, r in aws_route53_record.cname : k => r.fqdn },
    { for k, r in aws_route53_record.a : k => r.fqdn },
  )
}

output "cross_account_commands" {
  description = "Comando que a OUTRA conta executa para concluir a associação (sem ele a autorização fica pendente)."
  value = {
    for k, v in var.cross_account_vpcs :
    k => "aws route53 associate-vpc-with-hosted-zone --hosted-zone-id ${aws_route53_zone.this.zone_id} --vpc VPCRegion=${v.region},VPCId=${v.vpc_id}"
  }
}
