# Automação do lab "Automação de rotina operacional".
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

module "textract_pipeline" {
  source = "../../../../../aws/textract-pipeline"

  name_prefix = "demo-dev-ocr"
  kms_key_arn = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  tags        = local.tags
}
