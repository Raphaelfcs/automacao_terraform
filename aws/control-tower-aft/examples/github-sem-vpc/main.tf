# Exemplo "github-sem-vpc" do módulo aws/control-tower-aft: AFT com os quatro repositórios
# privados no GitHub e sem VPC (FinOps). Aplique com credenciais de administrador da conta de
# gerenciamento do Control Tower; o próprio AFT assume as roles nas demais contas.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "aft" {
  source = "../.."

  ct_management_account_id    = "123456789012"
  log_archive_account_id      = "210987654321"
  audit_account_id            = "222233334444"
  aft_management_account_id   = "345678901234"
  ct_home_region              = local.region
  tf_backend_secondary_region = "us-east-1"

  vcs_provider     = "github"
  repository_owner = "demo-org"

  tags = local.tags
}

output "post_deploy" {
  value = module.aft.post_deploy
}
