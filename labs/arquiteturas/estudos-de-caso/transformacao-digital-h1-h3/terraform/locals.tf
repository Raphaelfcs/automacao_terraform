locals {
  name_prefix = "demo-dev"
  region      = "sa-east-1"

  tags = {
    Projeto    = "demo"
    Ambiente   = "dev"
    Gerenciado = "terraform"
    Lab        = "transformacao-digital-h1-h3"
  }
}
