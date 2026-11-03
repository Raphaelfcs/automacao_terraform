locals {
  name_prefix = "demo-dev"
  region      = "us-east-1"

  # Endpoints fictícios: troque pelos da sua API de canais e de guia (EPG).
  url_canais    = "https://api.example.com/epg/canais?output=json"
  url_guia      = "https://api.example.com/epg/guia/{inicio}/{fim}?output=json"
  remetente     = "monitoria@example.com"
  destinatarios = ["noc@example.com"]

  tags = {
    Projeto    = "demo"
    Ambiente   = "dev"
    Gerenciado = "terraform"
    Lab        = "monitoria-de-guia"
  }
}
