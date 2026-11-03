# Automação do lab "Provisionamento de VMs automatizado".
# Compõe módulos do catálogo; cada módulo continua testado e versionado no próprio diretório.
# Dependências entre módulos são resolvidas pelas saídas (outputs) de um módulo nas entradas do outro.

provider "azurerm" {
  features {}

  subscription_id     = local.subscription_id
  storage_use_azuread = true
}

module "sql_database" {
  source = "../../../../../azure/sql-database"

  server_name                = "sql-demo-dev"
  resource_group_name        = "rg-dados"
  location                   = "brazilsouth"
  entra_admin_login          = "grp-dba"
  entra_admin_object_id      = "00000000-0000-0000-0000-000000000001"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoria/providers/Microsoft.OperationalInsights/workspaces/law-plataforma"
  databases                  = { cartoes = {}, conciliacao = { sku_name = "GP_Gen5_4", zone_redundant = true } }
  tags                       = local.tags
}

module "monitor_alerts" {
  source = "../../../../../azure/monitor-alerts"

  resource_group_name     = "rg-monitoria"
  action_group_name       = "ag-plataforma"
  action_group_short_name = "plataforma"
  emails                  = ["plataforma@example.com"]
  metric_alerts = {
    cpu-alta = { target_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app/providers/Microsoft.Compute/virtualMachines/vm-app-01"], metric_namespace = "Microsoft.Compute/virtualMachines", metric_name = "Percentage CPU", threshold = 85 }
    dtu-alta = { target_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dados/providers/Microsoft.Sql/servers/sql-demo/databases/app"], metric_namespace = "Microsoft.Sql/servers/databases", metric_name = "cpu_percent", threshold = 80, severity = 1 }
  }
  tags = local.tags
}
