# Exemplo "basico" do módulo aws/elasticache-redis: ElastiCache Valkey/Redis cifrado.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "elasticache_redis" {
  source = "../.."

  name_prefix             = local.name_prefix
  vpc_id                  = "vpc-0123456789abcdef0"
  subnet_ids              = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
  kms_key_arn             = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  engine_version          = "8.0"
  node_type               = "cache.t4g.micro"
  ingress_security_groups = { eks = "sg-0123456789abcdef0" }
  tags                    = local.tags
}
