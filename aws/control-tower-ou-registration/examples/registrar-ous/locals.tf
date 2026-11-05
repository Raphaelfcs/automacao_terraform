locals {
  # Home region do Control Tower: o provider precisa apontar para ela.
  region = "sa-east-1"

  tags = {
    Projeto    = "demo"
    Ambiente   = "global"
    Gerenciado = "terraform"
    Modulo     = "control-tower-ou-registration"
  }
}
