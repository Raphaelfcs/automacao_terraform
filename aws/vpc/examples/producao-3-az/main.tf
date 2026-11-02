# Exemplo "producao-3-az" do módulo aws/vpc: VPC em três camadas.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "vpc" {
  source = "../.."

  name_prefix              = "demo-prd"
  cidr_block               = "10.30.0.0/16"
  azs                      = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
  kms_key_arn              = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  flow_logs_retention_days = 90
  tags                     = local.tags
}
