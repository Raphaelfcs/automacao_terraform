resource "azurerm_resource_group" "this" {
  name     = local.nome
  location = var.location
  tags     = local.tags
}

resource "azurerm_management_lock" "this" {
  count      = var.bloquear_exclusao ? 1 : 0
  name       = "${local.nome}-nao-excluir"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Criado pela engine resource-group"
}
