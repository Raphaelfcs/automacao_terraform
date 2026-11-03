# Automação do lab "Integração de rede com parceiro".
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

module "route53_private_zone" {
  source = "../../../../../aws/route53-private-zone"

  zone_name          = "interno.demo.local"
  vpcs               = { principal = { vpc_id = module.vpc.vpc_id, region = "sa-east-1" } }
  cross_account_vpcs = { parceiro = { vpc_id = "vpc-0fedcba9876543210", region = "us-east-1" } }
  cname_records      = { db = "demo.abc123.sa-east-1.rds.amazonaws.com", api = "internal-api-123.sa-east-1.elb.amazonaws.com" }
  a_records          = { gateway = ["10.20.10.10", "10.20.11.10"] }
  tags               = local.tags
}

module "msk_kafka" {
  source = "../../../../../aws/msk-kafka"

  name_prefix             = local.name_prefix
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnet_ids
  kms_key_arn             = module.kms_key.key_arn
  kafka_version           = "3.7.x"
  broker_instance_type    = "kafka.t3.small"
  broker_count            = 3
  broker_volume_size      = 50
  ingress_security_groups = { eks = "sg-0123456789abcdef0" }
  client_topic_prefix     = "pedidos."
  tags                    = local.tags
}

module "elasticache_redis" {
  source = "../../../../../aws/elasticache-redis"

  name_prefix             = local.name_prefix
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.data_subnet_ids
  kms_key_arn             = module.kms_key.key_arn
  engine_version          = "8.0"
  node_type               = "cache.t4g.micro"
  ingress_security_groups = { eks = "sg-0123456789abcdef0" }
  tags                    = local.tags
}

module "rds_instance" {
  source = "../../../../../aws/rds-instance"

  name_prefix             = local.name_prefix
  engine                  = "mysql"
  engine_version          = "8.4.3"
  instance_class          = "db.t4g.micro"
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.data_subnet_ids
  kms_key_arn             = module.kms_key.key_arn
  database_name           = "app"
  ingress_security_groups = { eks = "sg-0123456789abcdef0" }
  deletion_protection     = false
  final_snapshot          = false
  tags                    = local.tags
}
