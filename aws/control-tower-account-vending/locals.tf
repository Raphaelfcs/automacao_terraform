locals {
  tags = merge({ Gerenciado = "terraform", Camada = "landing-zone" }, var.tags)

  # Nomes dos parâmetros exigidos pelo produto "AWS Control Tower Account Factory".
  parameters = {
    AccountName               = var.account_name
    AccountEmail              = var.account_email
    ManagedOrganizationalUnit = var.managed_organizational_unit
    SSOUserEmail              = coalesce(var.sso_user.email, var.account_email)
    SSOUserFirstName          = var.sso_user.first_name
    SSOUserLastName           = var.sso_user.last_name
  }

  outputs    = { for o in aws_servicecatalog_provisioned_product.account.outputs : o.key => o.value }
  account_id = lookup(local.outputs, "AccountId", null)
}
