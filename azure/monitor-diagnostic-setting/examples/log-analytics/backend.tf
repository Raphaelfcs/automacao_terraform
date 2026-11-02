# Estado remoto separado por módulo e exemplo (um state por ciclo de vida).
terraform {
  required_version = ">= 1.10"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstatedemo"
    container_name       = "tfstate"
    key                  = "azure/monitor-diagnostic-setting/log-analytics.tfstate"
    use_azuread_auth     = true
  }
}
