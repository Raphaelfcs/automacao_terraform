# Automação do lab "Fundamentos de AWS para o time".
# Compõe módulos do catálogo; cada módulo continua testado e versionado no próprio diretório.
# Dependências entre módulos são resolvidas pelas saídas (outputs) de um módulo nas entradas do outro.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "organizations_scp" {
  source = "../../../../../aws/organizations-scp"

  allowed_regions        = ["sa-east-1", "us-east-1"]
  required_tags          = ["CentroCusto", "Ambiente", "Dono"]
  create_tag_enforcement = ["CentroCusto"]
  attach_target          = ["Workloads", "Sandbox"]
  tags                   = local.tags
}

module "iam_group" {
  source = "../../../../../aws/iam-group"

  name                = "break-glass"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  require_mfa         = true
}

module "vpc" {
  source = "../../../../../aws/vpc"

  name_prefix        = local.name_prefix
  cidr_block         = "10.20.0.0/16"
  azs                = ["sa-east-1a", "sa-east-1b"]
  single_nat_gateway = true
  eks_cluster_name   = "demo-dev"
  tags               = local.tags
}

module "s3_bucket" {
  source = "../../../../../aws/s3-bucket"

  bucket_name = "demo-dev-dados-123456789012"
  tags        = local.tags
}
