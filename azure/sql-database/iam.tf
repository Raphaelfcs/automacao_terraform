# A identidade do servidor precisa ler a chave do TDE no Key Vault.
resource "azurerm_role_assignment" "tde" {
  count = var.tde_key_vault_id == null ? 0 : 1

  scope                = var.tde_key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_mssql_server.this.identity[0].principal_id
}
