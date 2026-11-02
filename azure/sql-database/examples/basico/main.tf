# Exemplo "basico" do módulo azure/sql-database: Azure SQL com Entra ID e auditoria.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "azurerm" {
  features {}

  subscription_id     = local.subscription_id
  storage_use_azuread = true
}

module "sql_database" {
  source = "../.."

  server_name                = "sql-demo-dev"
  resource_group_name        = "rg-dados"
  location                   = "brazilsouth"
  entra_admin_login          = "grp-dba"
  entra_admin_object_id      = "00000000-0000-0000-0000-000000000001"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoria/providers/Microsoft.OperationalInsights/workspaces/law-plataforma"
  databases                  = { cartoes = {}, conciliacao = { sku_name = "GP_Gen5_4", zone_redundant = true } }
  tags                       = local.tags
}
