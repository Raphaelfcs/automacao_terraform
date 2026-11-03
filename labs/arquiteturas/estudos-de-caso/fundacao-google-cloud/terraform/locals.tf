locals {
  project_id = "demo-plataforma-dev"
  region     = "southamerica-east1"

  labels = {
    projeto    = "demo"
    ambiente   = "dev"
    gerenciado = "terraform"
    lab     = "fundacao-google-cloud"
  }
}
