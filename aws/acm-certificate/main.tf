# Certificado ACM validado por DNS numa zona do Route 53. Para CloudFront, crie com provider em
# us-east-1. A validação espera o certificado ficar emitido antes de liberar dependentes.

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
  key_algorithm             = var.key_algorithm

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# Chaves pelos nomes declarados (conhecidos no plan); os valores de validação só existem no apply.
resource "aws_route53_record" "validacao" {
  for_each = toset(concat([var.domain_name], var.subject_alternative_names))

  zone_id         = var.zone_id
  name            = one([for o in aws_acm_certificate.this.domain_validation_options : o.resource_record_name if o.domain_name == each.key])
  type            = one([for o in aws_acm_certificate.this.domain_validation_options : o.resource_record_type if o.domain_name == each.key])
  records         = [one([for o in aws_acm_certificate.this.domain_validation_options : o.resource_record_value if o.domain_name == each.key])]
  ttl             = 300
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for r in aws_route53_record.validacao : r.fqdn]
}
