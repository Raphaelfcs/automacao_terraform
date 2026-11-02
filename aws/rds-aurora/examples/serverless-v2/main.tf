# Exemplo "serverless-v2" do módulo aws/rds-aurora: Amazon Aurora (MySQL/PostgreSQL, provisionado ou Serverless v2).
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "rds_aurora" {
  source = "../.."

  name                   = "${local.name_prefix}-sls"
  engine                 = "aurora-postgresql"
  engine_version         = "16.4"
  parameter_group_family = "aurora-postgresql16"
  serverless_v2          = { min_capacity = 0.5, max_capacity = 8 }
  instances              = { "1" = {} }
  vpc_id                 = "vpc-0123456789abcdef0"
  subnet_ids             = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
  kms_key_arn            = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  deletion_protection    = false
  final_snapshot         = false
  tags                   = local.tags
}
