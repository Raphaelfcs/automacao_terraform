locals {
  nome = "docs-${var.ambiente}"
  labels = {
    projeto      = "docs-pacientes"
    ambiente     = var.ambiente
    dados        = "saude-sensivel"
    centro_custo = "plataforma-docs"
    gerenciado   = "terraform"
  }

  base    = data.terraform_remote_state.gcp_base.outputs
  aws     = data.terraform_remote_state.aws_base.outputs
  ids     = data.terraform_remote_state.aws_identidade.outputs
  aws_app = data.terraform_remote_state.aws_app.outputs

  ambiente_run = {
    NUVEM                 = "gcp"
    GCP_PROJETO           = var.projeto_gcp
    GCP_BANCO             = local.base.firestore_banco
    GCP_BUCKET            = local.base.bucket_documentos
    AWS_ROLE_FEDERADA     = local.aws_app.role_gcp_arn
    AWS_REGIAO            = "sa-east-1"
    TABELA                = local.aws.tabela_nome
    BUCKET                = local.aws.bucket_documentos
    EMISSORES             = local.ids.emissores
    COGNITO_REGIAO        = "sa-east-1"
    COGNITO_POOL_EQUIPE   = local.ids.pool_equipe_id
    COGNITO_POOL_PACIENTE = local.ids.pool_pacientes_id
  }

  csp = join("; ", [
    "default-src 'self'", "script-src 'self'", "style-src 'self'", "img-src 'self' data:", "manifest-src 'self'", "worker-src 'self'",
    "connect-src 'self' https://${local.ids.config_web.equipe.dominio} https://${local.ids.config_web.paciente.dominio} https://${local.aws.bucket_documentos}.s3.amazonaws.com https://${local.aws.bucket_documentos}.s3.sa-east-1.amazonaws.com https://storage.googleapis.com",
    "frame-ancestors 'none'", "base-uri 'none'", "object-src 'none'", "form-action 'self'",
  ])
}
