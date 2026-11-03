# Automação do lab "MVP de automação de processos com IA".
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

module "eventbridge_bus_sqs" {
  source = "../../../../../aws/eventbridge-bus-sqs"

  name_prefix             = local.name_prefix
  queue_name              = "pedidos"
  event_sources           = ["parceiro.pedidos"]
  detail_types            = ["PedidoConcluido"]
  producer_principal_arns = ["arn:aws:iam::210987654321:role/parceiro-eventbridge"]
  kms_key_arn             = module.kms_key.key_arn
  consumer_role_name      = "demo-dev-consumidor"
  alarm_actions           = ["arn:aws:sns:sa-east-1:123456789012:demo-dev-alertas"]
  tags                    = local.tags
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

module "cloudfront_spa" {
  source = "../../../../../aws/cloudfront-spa"

  name_prefix = local.name_prefix
  app_name    = "web"
  dist_path   = "${path.module}/dist"
  tags        = local.tags
}
