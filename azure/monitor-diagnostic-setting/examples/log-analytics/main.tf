# Exemplo "log-analytics" do módulo azure/monitor-diagnostic-setting: Diagnostic settings em lote.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "azurerm" {
  features {}

  subscription_id     = local.subscription_id
  storage_use_azuread = true
}

module "monitor_diagnostic_setting" {
  source = "../.."

  target_resource_ids        = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app/providers/Microsoft.KeyVault/vaults/kv-demo"]
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoria/providers/Microsoft.OperationalInsights/workspaces/law-plataforma"
}
