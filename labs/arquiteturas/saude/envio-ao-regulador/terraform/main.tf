# Automação do lab "Envio periódico ao órgão regulador".
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

module "sqs_queue" {
  source = "../../../../../aws/sqs-queue"

  name_prefix = "demo-dev-"
  queues      = ["pedidos", "notificacoes"]
  tags        = local.tags
}

module "lambda_function" {
  source = "../../../../../aws/lambda-function"

  function_name       = "demo-dev-relatorio"
  source_dir          = "${path.module}/src"
  schedule_expression = "rate(1 day)"
  environment         = { NIVEL_LOG = "INFO" }
  tags                = local.tags
}

module "s3_bucket" {
  source = "../../../../../aws/s3-bucket"

  bucket_name = "demo-dev-dados-123456789012"
  tags        = local.tags
}
