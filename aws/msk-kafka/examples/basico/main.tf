# Exemplo "basico" do módulo aws/msk-kafka: Amazon MSK com SASL/IAM.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "msk_kafka" {
  source = "../.."

  name_prefix             = local.name_prefix
  vpc_id                  = "vpc-0123456789abcdef0"
  subnet_ids              = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f", "subnet-0ggg5555hhhh6666i"]
  kms_key_arn             = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  kafka_version           = "3.7.x"
  broker_instance_type    = "kafka.t3.small"
  broker_count            = 3
  broker_volume_size      = 50
  ingress_security_groups = { eks = "sg-0123456789abcdef0" }
  client_topic_prefix     = "pedidos."
  tags                    = local.tags
}
