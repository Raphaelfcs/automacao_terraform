locals {
  region = "sa-east-1"

  tags = {
    Projeto    = "demo"
    Ambiente   = "dev"
    Gerenciado = "terraform"
    Modulo     = "s3-bucket"
  }
}
