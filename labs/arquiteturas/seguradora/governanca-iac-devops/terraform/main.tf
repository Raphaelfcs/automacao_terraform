# Automação do lab "Governança, IaC e DevOps".
# Compõe módulos do catálogo; cada módulo continua testado e versionado no próprio diretório.
# Dependências entre módulos são resolvidas pelas saídas (outputs) de um módulo nas entradas do outro.

provider "azurerm" {
  features {}

  subscription_id     = local.subscription_id
  storage_use_azuread = true
}

module "storage_account" {
  source = "../../../../../azure/storage-account"

  name                 = "stdemodev001"
  resource_group_name  = "rg-demo-dev"
  location             = "brazilsouth"
  cmk_key_vault_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-demo-dev/providers/Microsoft.KeyVault/vaults/kv-demo-dev"
  cmk_key_vault_key_id = "https://kv-demo-dev.vault.azure.net/keys/storage"
  containers           = ["dados", "backup"]
  tags                 = local.tags
}

module "monitor_diagnostic_setting" {
  source = "../../../../../azure/monitor-diagnostic-setting"

  target_resource_ids        = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app/providers/Microsoft.KeyVault/vaults/kv-demo"]
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoria/providers/Microsoft.OperationalInsights/workspaces/law-plataforma"
}
