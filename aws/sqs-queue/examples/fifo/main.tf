# Exemplo "fifo" do módulo aws/sqs-queue: Filas SQS com DLQ.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "sqs_queue" {
  source = "../.."

  name_prefix                = "demo-dev-"
  queues                     = ["pagamentos"]
  fifo                       = true
  kms_key_arn                = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  visibility_timeout_seconds = 180
  tags                       = local.tags
}
