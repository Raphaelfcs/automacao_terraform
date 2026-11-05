# Exemplo "conta-aft" do módulo aws/control-tower-account-vending: cria pela Account Factory a
# conta dedicada ao AFT, pré-requisito do módulo control-tower-aft.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "aft_management_account" {
  source = "../.."

  account_name                = "demo-aft-management"
  account_email               = "aws+demo-aft-management@example.com"
  managed_organizational_unit = "AFT"
  sso_user = {
    first_name = "Plataforma"
    last_name  = "AFT"
  }
  tags = local.tags
}

output "aft_management_account_id" {
  value = module.aft_management_account.account_id
}
