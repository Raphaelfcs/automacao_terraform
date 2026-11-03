locals {
  region = "sa-east-1"

  tags = {
    Projeto    = "demo"
    Ambiente   = "dev"
    Gerenciado = "terraform"
    Lab        = "workflow-multi-x-mono-repo"
  }
}
