locals {
  nome = "docs-${var.ambiente}"
  tags = {
    Projeto     = "docs-pacientes"
    Ambiente    = var.ambiente
    Dados       = "saude-sensivel"
    CentroCusto = "plataforma-docs"
    Gerenciado  = "terraform"
  }

  base = data.terraform_remote_state.aws_base.outputs
  ids  = data.terraform_remote_state.aws_identidade.outputs
  gcp  = data.terraform_remote_state.gcp_base.outputs

  codigo_lambda = "${path.module}/../../../app/build/lambda" # make -C app lambda (pipeline) antes do plan
  bucket_arn    = local.base.bucket_documentos_arn

  # Mesmas variáveis nas três funções: o código decide o que usar.
  ambiente_lambda = {
    NUVEM                 = "aws"
    TABELA                = local.base.tabela_nome
    BUCKET                = local.base.bucket_documentos
    GCP_PROJETO           = local.gcp.projeto
    GCP_BANCO             = local.gcp.firestore_banco
    GCP_BUCKET            = local.gcp.bucket_documentos
    GCP_CONTA_ASSINATURA  = local.gcp.conta_federada
    GCP_CRED_CONFIG       = local.gcp.federacao_config
    EMISSORES             = local.ids.emissores
    COGNITO_REGIAO        = var.regiao
    COGNITO_POOL_EQUIPE   = local.ids.pool_equipe_id
    COGNITO_POOL_PACIENTE = local.ids.pool_pacientes_id
  }

  kms = { Effect = "Allow", Action = ["kms:Decrypt", "kms:GenerateDataKey"], Resource = local.base.kms_arn }
  lista_docs = {
    Effect    = "Allow"
    Action    = "s3:ListBucket" # HeadObject de objeto inexistente responde 404 (e não 403) só com ListBucket
    Resource  = local.bucket_arn
    Condition = { StringLike = { "s3:prefix" = ["clinicas/*"] } }
  }
  tabela = [local.base.tabela_arn, "${local.base.tabela_arn}/index/*"]

  # Ninguém tem DeleteItem nem UpdateItem: itens são inseridos ou substituídos com condição.
  politica_api = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query"], Resource = local.tabela },
    { Effect = "Allow", Action = ["s3:GetObject", "s3:PutObject"], Resource = "${local.bucket_arn}/clinicas/*" },
    local.lista_docs, local.kms,
    { Effect = "Allow", Action = ["cognito-idp:AdminCreateUser", "cognito-idp:AdminGetUser"], Resource = local.ids.pool_arns },
  ] })
  politica_eventos = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["dynamodb:GetItem", "dynamodb:PutItem"], Resource = local.base.tabela_arn },
    { Effect = "Allow", Action = ["s3:GetObject", "s3:DeleteObject"], Resource = "${local.bucket_arn}/clinicas/*" },
    local.lista_docs, local.kms,
  ] })
  politica_replicador = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["s3:GetObject"], Resource = "${local.bucket_arn}/clinicas/*" },
    local.lista_docs, local.kms,
  ] })
  # Cloud Run (GCP) chegando na AWS pela role federada: o mesmo que a API e os eventos fazem aqui.
  politica_gcp = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query"], Resource = local.tabela },
    { Effect = "Allow", Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"], Resource = "${local.bucket_arn}/clinicas/*" },
    local.lista_docs, local.kms,
    { Effect = "Allow", Action = ["cognito-idp:AdminCreateUser", "cognito-idp:AdminGetUser"], Resource = local.ids.pool_arns },
  ] })

  csp = join("; ", [
    "default-src 'self'", "script-src 'self'", "style-src 'self'", "img-src 'self' data:", "manifest-src 'self'", "worker-src 'self'",
    "connect-src 'self' https://${local.ids.config_web.equipe.dominio} https://${local.ids.config_web.paciente.dominio} https://${local.base.bucket_documentos}.s3.amazonaws.com https://${local.base.bucket_documentos}.s3.${var.regiao}.amazonaws.com https://storage.googleapis.com",
    "frame-ancestors 'none'", "base-uri 'none'", "object-src 'none'", "form-action 'self'",
  ])
}
