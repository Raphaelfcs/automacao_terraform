locals {
  tags = merge({ Gerenciado = "terraform", Camada = "dns" }, var.tags)

  # Domínio e curinga geram o MESMO registro de validação, então basta o do domínio. A chave do
  # for_each é o próprio domínio (conhecido no plan); nome e valor do registro só existem depois
  # que o certificado é criado e por isso ficam nos valores.
  validation_keys = var.create_wildcard_certificate ? toset([var.zone_name]) : toset([])

  validation_option = var.create_wildcard_certificate ? one([
    for o in aws_acm_certificate.wildcard[0].domain_validation_options : o if o.domain_name == var.zone_name
  ]) : null
}
