locals {
  tags = merge({ Gerenciado = "terraform", Camada = "dns" }, var.tags)

  # Domínio e curinga geram o MESMO registro de validação: basta o do domínio. A chave é o nome
  # de domínio (conhecido no plan), não o nome do registro (só existe depois do apply).
  validation_records = var.create_wildcard_certificate ? {
    for o in aws_acm_certificate.wildcard[0].domain_validation_options : o.domain_name => {
      name   = o.resource_record_name
      type   = o.resource_record_type
      record = o.resource_record_value
    } if !startswith(o.domain_name, "*.")
  } : {}
}
