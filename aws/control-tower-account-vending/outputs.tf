output "account_id" {
  description = "ID da conta criada."
  value       = local.account_id
}

output "provisioned_product_id" {
  description = "ID do produto provisionado no Service Catalog (para atualizar/encerrar a conta)."
  value       = aws_servicecatalog_provisioned_product.account.id
}

output "status" {
  description = "Situação do provisionamento (AVAILABLE quando concluído)."
  value       = aws_servicecatalog_provisioned_product.account.status
}
