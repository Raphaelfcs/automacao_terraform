# Automação do lab "Visão geral da plataforma AWS de uma operadora de saúde".
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

module "vpc_endpoints" {
  source = "../../../../../aws/vpc-endpoints"

  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  route_table_ids    = module.vpc.private_route_table_ids
  interface_services = ["ssm", "ssmmessages", "ec2messages", "ecr.api", "ecr.dkr", "logs", "sts"]
  tags               = local.tags
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

module "backup_plan" {
  source = "../../../../../aws/backup-plan"

  name_prefix            = local.name_prefix
  kms_key_arn            = module.kms_key.key_arn
  notification_topic_arn = "arn:aws:sns:sa-east-1:123456789012:demo-dev-alertas"
  tags                   = local.tags
}
