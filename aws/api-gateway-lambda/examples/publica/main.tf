# Exemplo "publica" do módulo aws/api-gateway-lambda: HTTP API -> Lambda.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "api_gateway_lambda" {
  source = "../.."

  name                 = "demo-dev-api"
  lambda_function_name = "demo-dev-processa"
  lambda_invoke_arn    = "arn:aws:apigateway:sa-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:sa-east-1:123456789012:function:demo-dev-processa/invocations"
  tags                 = local.tags
}
