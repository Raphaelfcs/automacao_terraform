# Estado isolado por lab (um state por ciclo de vida).
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
    key                  = "labs/finops/finops-atual-x-alvo.tfstate"
    use_azuread_auth     = true
  }
}
