locals {
  region = "us-east-1"

  tags = {
    Projeto    = "demo"
    Ambiente   = "dev"
    Gerenciado = "terraform"
    Modulo     = "cur-focus-export"
  }
}
