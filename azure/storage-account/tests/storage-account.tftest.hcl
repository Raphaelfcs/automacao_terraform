# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "azurerm" {
  mock_resource "azurerm_monitor_action_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Insights/actionGroups/ag-mock"
    }
  }
  mock_resource "azurerm_mssql_server" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.Sql/servers/sql-mock"
    }
  }
  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-mock/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-mock"
      principal_id = "11111111-2222-3333-4444-555555555555"
      client_id    = "11111111-2222-3333-4444-555555555556"
    }
  }
  mock_data "azurerm_monitor_diagnostic_categories" {
    defaults = {
      log_category_types = ["AuditEvent"]
      metrics            = ["AllMetrics"]
    }
  }

  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id       = "00000000-0000-0000-0000-000000000000"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      object_id       = "00000000-0000-0000-0000-000000000001"
    }
  }
}

run "exemplo_cmk" {
  command = apply

  variables {
    name                 = "stdemodev001"
    resource_group_name  = "rg-demo-dev"
    location             = "brazilsouth"
    cmk_key_vault_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-demo-dev/providers/Microsoft.KeyVault/vaults/kv-demo-dev"
    cmk_key_vault_key_id = "https://kv-demo-dev.vault.azure.net/keys/storage"
    containers           = ["dados", "backup"]
    tags                 = { Projeto = "demo", Ambiente = "teste" }
  }
}
