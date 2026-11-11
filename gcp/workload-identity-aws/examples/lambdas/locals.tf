locals {
  project_id = "demo-plataforma-dev"
  region     = "southamerica-east1"

  labels = {
    projeto    = "demo"
    ambiente   = "dev"
    gerenciado = "terraform"
    modulo     = "workload-identity-aws"
  }
}
