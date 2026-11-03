# Automação do lab "Pipeline de deploy por ambiente".
# Compõe módulos do catálogo; cada módulo continua testado e versionado no próprio diretório.
# Dependências entre módulos são resolvidas pelas saídas (outputs) de um módulo nas entradas do outro.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "iam_github_oidc" {
  source = "../../../../../aws/iam-github-oidc"

  github_org           = "minha-org"
  github_repo          = "infra"
  allowed_environments = ["dev", "prd"]
  managed_role_prefix  = "app-"
  state_bucket_arn     = "arn:aws:s3:::demo-tfstate-123456789012"
  tags                 = local.tags
}

module "ecr" {
  source = "../../../../../aws/ecr"

  name_prefix      = "demo"
  repository_names = ["api", "worker"]
  tags             = local.tags
}
