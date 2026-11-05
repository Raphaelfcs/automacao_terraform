# Exemplo "registrar-ous" do módulo aws/control-tower-ou-registration: registra as OUs de
# infraestrutura e de workloads (com as filhas Dev e Prd) depois da landing zone.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "ou_registration" {
  source = "../.."

  organizational_units = {
    Infrastructure = { arn = "arn:aws:organizations::123456789012:ou/o-abcd123456/ou-ab12-11111111" }
    Workloads      = { arn = "arn:aws:organizations::123456789012:ou/o-abcd123456/ou-ab12-22222222" }
    Dev            = { arn = "arn:aws:organizations::123456789012:ou/o-abcd123456/ou-ab12-33333333", parent = "Workloads" }
    Prd            = { arn = "arn:aws:organizations::123456789012:ou/o-abcd123456/ou-ab12-44444444", parent = "Workloads" }
  }

  identity_center_enabled_baseline_arn = "arn:aws:controltower:sa-east-1:123456789012:enabledbaseline/XAHCR4CJTSI4W07MZ"
  tags                                 = local.tags
}
