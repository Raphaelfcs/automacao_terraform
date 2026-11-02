# Exemplo "cross-account" do módulo aws/ecr: Repositórios ECR com scan, KMS e retenção.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "ecr" {
  source = "../.."

  name_prefix          = "demo"
  repository_names     = ["api"]
  kms_key_arn          = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  release_tag_prefixes = ["v"]
  pull_principal_arns  = ["arn:aws:iam::210987654321:root"]
  push_principal_arns  = ["arn:aws:iam::123456789012:role/github-demo-deploy"]
  tags                 = local.tags
}
