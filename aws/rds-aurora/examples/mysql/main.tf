# Exemplo "mysql" do módulo aws/rds-aurora: Amazon Aurora (MySQL/PostgreSQL, provisionado ou Serverless v2).
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "rds_aurora" {
  source = "../.."

  name                   = "${local.name_prefix}-my"
  engine                 = "aurora-mysql"
  engine_version         = "8.0.mysql_aurora.3.08.0"
  parameter_group_family = "aurora-mysql8.0"
  backtrack_window_hours = 24
  vpc_id                 = "vpc-0123456789abcdef0"
  subnet_ids             = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
  kms_key_arn            = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  tags                   = local.tags
}
