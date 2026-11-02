# Exemplo "vpc-sqs" do módulo aws/lambda-function: Função Lambda empacotada.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "lambda_function" {
  source = "../.."

  function_name   = "demo-dev-processa"
  source_dir      = "${path.module}/src"
  vpc             = { subnet_ids = ["subnet-0aaa1111bbbb2222c"], security_group_ids = ["sg-0123456789abcdef0"] }
  sqs_trigger_arn = "arn:aws:sqs:sa-east-1:123456789012:demo-dev-pedidos"
  tracing         = true
  tags            = local.tags
}
