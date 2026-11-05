# Zona Route 53 PÚBLICA de um domínio ou subdomínio (ex.: example.com na conta de produção e
# dev.example.com na conta de dev), com certificado ACM curinga validado por DNS e registro CAA
# que restringe a emissão à Amazon. A delegação do subdomínio para a zona pai é feita pelo módulo
# route53-zone-delegation, em estado próprio (interconexão entre contas).

resource "aws_route53_zone" "this" {
  name          = var.zone_name
  comment       = var.comment
  force_destroy = false
  tags          = local.tags
}

resource "aws_route53_record" "caa" {
  count = length(var.caa_issuers) > 0 ? 1 : 0

  zone_id = aws_route53_zone.this.zone_id
  name    = var.zone_name
  type    = "CAA"
  ttl     = 3600
  records = [for i in var.caa_issuers : "0 issue \"${i}\""]
}

# Curinga cobre um nível só: *.example.com não vale para a.b.example.com.
resource "aws_acm_certificate" "wildcard" {
  count = var.create_wildcard_certificate ? 1 : 0

  domain_name               = var.zone_name
  subject_alternative_names = ["*.${var.zone_name}"]
  validation_method         = "DNS"
  key_algorithm             = var.certificate_key_algorithm
  tags                      = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = local.validation_records

  zone_id         = aws_route53_zone.this.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 300
  records         = [each.value.record]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "wildcard" {
  count = var.create_wildcard_certificate && var.wait_for_validation ? 1 : 0

  certificate_arn         = aws_acm_certificate.wildcard[0].arn
  validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
}
