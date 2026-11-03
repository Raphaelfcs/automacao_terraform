locals {
  name_prefix = "demo-dev"
  region      = "us-east-1"

  tags = {
    Projeto    = "demo"
    Ambiente   = "dev"
    Gerenciado = "terraform"
    Lab        = "processo-finops"
  }
}
