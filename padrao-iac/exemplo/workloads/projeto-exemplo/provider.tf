terraform {
  required_version = ">= 1.7"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
  backend "azurerm" {} # configurado por envs/<ambiente>/backend.hcl
}

provider "azurerm" {
  features {}
  use_oidc = true # credencial temporária do pipeline (GitLab, GitHub ou Azure DevOps)
}
