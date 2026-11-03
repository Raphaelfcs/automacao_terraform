# Automação do lab "EKS para funções de core 5G".
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

module "transit_gateway_attachment" {
  source = "../../../../../aws/transit-gateway-attachment"

  name_prefix        = local.name_prefix
  transit_gateway_id = "tgw-0123456789abcdef0"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  route_table_ids    = module.vpc.private_route_table_ids
  remote_cidrs       = ["10.0.0.0/8", "172.16.0.0/12"]
  tags               = local.tags
}

module "ecr" {
  source = "../../../../../aws/ecr"

  name_prefix      = "demo"
  repository_names = ["api", "worker"]
  tags             = local.tags
}
