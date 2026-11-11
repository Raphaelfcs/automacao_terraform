locals {
  nome = "docs-${var.ambiente}"
  labels = {
    projeto      = "docs-pacientes"
    ambiente     = var.ambiente
    dados        = "saude-sensivel"
    centro_custo = "plataforma-docs"
    gerenciado   = "terraform"
  }
}
