# Automação do lab "Desafio: aplicação web escalável".
# Compõe módulos do catálogo; cada módulo continua testado e versionado no próprio diretório.
# Dependências entre módulos são resolvidas pelas saídas (outputs) de um módulo nas entradas do outro.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "s3_bucket" {
  source = "../../../../../aws/s3-bucket"

  bucket_name = "demo-dev-dados-123456789012"
  tags        = local.tags
}

module "lambda_function" {
  source = "../../../../../aws/lambda-function"

  function_name       = "demo-dev-relatorio"
  source_dir          = "${path.module}/src"
  schedule_expression = "rate(1 day)"
  environment         = { NIVEL_LOG = "INFO" }
  tags                = local.tags
}

module "api_gateway_lambda" {
  source = "../../../../../aws/api-gateway-lambda"

  name                 = "demo-dev-api"
  lambda_function_name = module.lambda_function.function_name
  lambda_invoke_arn    = module.lambda_function.invoke_arn
  tags                 = local.tags
}

module "sns_topic" {
  source = "../../../../../aws/sns-topic"

  name_prefix        = "demo-dev-"
  topic_names        = ["alertas"]
  kms_key_arn        = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  publisher_services = ["events.amazonaws.com", "cloudwatch.amazonaws.com"]
  subscriptions      = { alertas = [{ protocol = "email", endpoint = "plataforma@example.com" }] }
  tags               = local.tags
}

module "cloudfront_spa" {
  source = "../../../../../aws/cloudfront-spa"

  name_prefix = local.name_prefix
  app_name    = "web"
  dist_path   = "${path.module}/dist"
  tags        = local.tags
}
