# Exemplo "postgres-multi-az" do módulo aws/rds-instance: RDS MySQL/PostgreSQL privado.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "rds_instance" {
  source = "../.."

  name_prefix                  = local.name_prefix
  engine                       = "postgres"
  engine_version               = "16.4"
  instance_class               = "db.r7g.large"
  multi_az                     = true
  vpc_id                       = "vpc-0123456789abcdef0"
  subnet_ids                   = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
  kms_key_arn                  = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  database_name                = "app"
  backup_retention_period      = 14
  enhanced_monitoring_interval = 60
  tags                         = local.tags
}
