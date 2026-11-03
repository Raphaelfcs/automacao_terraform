# Automação do lab "Simulador de prévia de gastos".
# Compõe módulos do catálogo; cada módulo continua testado e versionado no próprio diretório.
# Dependências entre módulos são resolvidas pelas saídas (outputs) de um módulo nas entradas do outro.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "kms_key" {
  source = "../../../../../aws/kms-key"

  name_prefix             = local.name_prefix
  deletion_window_in_days = 7
  tags                    = local.tags
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

module "eks_cluster" {
  source = "../../../../../aws/eks-cluster"

  cluster_name       = "demo-dev"
  kubernetes_version = "1.31"
  subnet_ids         = module.vpc.private_subnet_ids
  kms_key_arn        = module.kms_key.key_arn
  node_pools = {
    sistema = { instance_types = ["t3.medium"], desired_size = 2, min_size = 1, max_size = 3, labels = { role = "system" }, taints = [{ key = "CriticalAddonsOnly", value = "true", effect = "NO_SCHEDULE" }] }
    apps    = { instance_types = ["m7i.large"], desired_size = 2, min_size = 2, max_size = 10 }
  }
  tags = local.tags
}

module "cloudfront_spa" {
  source = "../../../../../aws/cloudfront-spa"

  name_prefix = local.name_prefix
  app_name    = "web"
  dist_path   = "${path.module}/dist"
  tags        = local.tags
}

module "route53_private_zone" {
  source = "../../../../../aws/route53-private-zone"

  zone_name          = "interno.demo.local"
  vpcs               = { principal = { vpc_id = module.vpc.vpc_id, region = "sa-east-1" } }
  cross_account_vpcs = { parceiro = { vpc_id = "vpc-0fedcba9876543210", region = "us-east-1" } }
  cname_records      = { db = "demo.abc123.sa-east-1.rds.amazonaws.com", api = "internal-api-123.sa-east-1.elb.amazonaws.com" }
  a_records          = { gateway = ["10.20.10.10", "10.20.11.10"] }
  tags               = local.tags
}
