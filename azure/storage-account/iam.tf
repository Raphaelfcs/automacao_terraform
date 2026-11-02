# Identidade gerenciada usada para ler a CMK no Key Vault (wrap/unwrap).
resource "azurerm_user_assigned_identity" "storage" {
  name                = "${var.name}-id"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "cmk" {
  count = var.cmk_key_vault_id == null ? 0 : 1

  scope                = var.cmk_key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}

# Acesso a dados por RBAC (Entra ID), não por chave de conta.
resource "azurerm_role_assignment" "data" {
  for_each = var.data_contributors

  scope                = azurerm_storage_account.this.id
  role_definition_name = each.value
  principal_id         = each.key
}
