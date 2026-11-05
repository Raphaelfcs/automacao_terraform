# Exemplo "teto-organizacao" do módulo aws/budget-guardrail: teto de US$ 450/mês para a
# organização inteira, com congelamento automático das OUs de workload ao atingir 100%.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "teto" {
  source = "../.."

  name              = "demo-teto-mensal"
  limit_usd         = 450
  alert_emails      = ["finops@example.com"]
  freeze_target_ids = ["ou-ab12-22222222", "ou-ab12-55555555"]
  tags              = local.tags
}
