locals {
  nome = "docs-${var.ambiente}"
  tags = {
    Projeto     = "docs-pacientes"
    Ambiente    = var.ambiente
    Dados       = "saude-sensivel"
    CentroCusto = "plataforma-docs"
    Gerenciado  = "terraform"
  }

  aws_app = data.terraform_remote_state.aws_app.outputs
  gcp_app = data.terraform_remote_state.gcp_app.outputs
}
