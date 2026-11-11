# Registros DNS avulsos numa zona existente (validação de certificado de outra nuvem, verificação
# de domínio, CNAMEs). Mantém registros de ciclo de vida diferente fora do estado da zona.

resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = each.value.ttl
  records = each.value.values
}
