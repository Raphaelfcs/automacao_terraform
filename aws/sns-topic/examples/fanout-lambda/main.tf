# Exemplo "fanout-lambda" do módulo aws/sns-topic: Tópicos SNS com assinaturas.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "sns_topic" {
  source = "../.."

  name_prefix   = "demo-dev-"
  topic_names   = ["documentos"]
  subscriptions = { documentos = [{ protocol = "lambda", endpoint = "arn:aws:lambda:sa-east-1:123456789012:function:demo-dev-processa" }] }
  tags          = local.tags
}
