locals {
  nome = "docs-${var.ambiente}"
  tags = {
    Projeto     = "docs-pacientes"
    Ambiente    = var.ambiente
    Dados       = "saude-sensivel"
    CentroCusto = "plataforma-docs"
    Gerenciado  = "terraform"
  }
}
