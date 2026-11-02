# Exemplo "avancado" do módulo aws/rds-aurora: Amazon Aurora (MySQL/PostgreSQL, provisionado ou Serverless v2).
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "rds_aurora" {
  source = "../.."

  name                         = "${local.name_prefix}-adv"
  engine                       = "aurora-postgresql"
  engine_version               = "16.4"
  parameter_group_family       = "aurora-postgresql16"
  vpc_id                       = "vpc-0123456789abcdef0"
  subnet_ids                   = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
  kms_key_arn                  = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  ingress_security_groups      = { eks = "sg-0123456789abcdef0" }
  ingress_cidrs                = ["10.100.0.0/16"]
  replica_autoscaling          = { min_capacity = 1, max_capacity = 4, target_cpu = 65 }
  enhanced_monitoring_interval = 30
  iam_database_authentication  = true
  backup_retention_period      = 21
  tags                         = local.tags
}
