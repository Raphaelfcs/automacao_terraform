locals {
  name_prefix = "demo-dev"
  region      = "sa-east-1"

  tags = {
    Projeto    = "demo"
    Ambiente   = "dev"
    Gerenciado = "terraform"
    Modulo     = "cloudwatch-logs"
  }
}
