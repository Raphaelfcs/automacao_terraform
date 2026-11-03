# Automação do lab "OCR de documentos em escala".
# Compõe módulos do catálogo; cada módulo continua testado e versionado no próprio diretório.
# Dependências entre módulos são resolvidas pelas saídas (outputs) de um módulo nas entradas do outro.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "kms_key" {
  source = "../../../../../aws/kms-key"

  name_prefix             = local.name_prefix
  deletion_window_in_days = 7
  tags                    = local.tags
}

module "textract_pipeline" {
  source = "../../../../../aws/textract-pipeline"

  name_prefix = "demo-dev-ocr"
  kms_key_arn = module.kms_key.key_arn
  tags        = local.tags
}

module "sqs_queue" {
  source = "../../../../../aws/sqs-queue"

  name_prefix = "demo-dev-"
  queues      = ["pedidos", "notificacoes"]
  tags        = local.tags
}

module "sns_topic" {
  source = "../../../../../aws/sns-topic"

  name_prefix        = "demo-dev-"
  topic_names        = ["alertas"]
  kms_key_arn        = module.kms_key.key_arn
  publisher_services = ["events.amazonaws.com", "cloudwatch.amazonaws.com"]
  subscriptions      = { alertas = [{ protocol = "email", endpoint = "plataforma@example.com" }] }
  tags               = local.tags
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

module "cognito_user_pool" {
  source = "../../../../../aws/cognito-user-pool"

  name_prefix       = local.name_prefix
  domain_prefix     = "demo-dev-login"
  callback_urls     = ["https://app.example.com/callback"]
  logout_urls       = ["https://app.example.com/"]
  custom_attributes = { tenant_id = 64 }
  roles             = { admin = "Administradores", operador = "Operacao" }
  machine_scopes    = { "pedidos.read" = "Ler pedidos", "pedidos.write" = "Gravar pedidos" }
  service_clients   = { faturamento = ["pedidos.read"] }
  tags              = local.tags
}
