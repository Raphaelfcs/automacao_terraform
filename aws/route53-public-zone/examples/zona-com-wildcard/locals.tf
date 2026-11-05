locals {
  # Home region do Control Tower: o provider precisa apontar para ela.
  region = "sa-east-1"

  tags = {
    Projeto    = "demo"
    Ambiente   = "dev"
    Gerenciado = "terraform"
    Modulo     = "route53-public-zone"
  }
}
