# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id       = "00000000-0000-0000-0000-000000000000"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      object_id       = "00000000-0000-0000-0000-000000000001"
    }
  }
}

run "exemplo_basico" {
  command = apply

  variables {
    server_name                = "sql-demo-dev"
    resource_group_name        = "rg-dados"
    location                   = "brazilsouth"
    entra_admin_login          = "grp-dba"
    entra_admin_object_id      = "00000000-0000-0000-0000-000000000001"
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoria/providers/Microsoft.OperationalInsights/workspaces/law-plataforma"
    databases                  = { cartoes = {}, conciliacao = { sku_name = "GP_Gen5_4", zone_redundant = true } }
    tags                       = { Projeto = "demo", Ambiente = "teste" }
  }
}
