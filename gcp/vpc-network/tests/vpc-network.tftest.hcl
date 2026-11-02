# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

run "exemplo_gke" {
  command = apply

  variables {
    project_id = "demo-plataforma-dev"
    region     = "sa-east-1"
    subnet     = { name = "sn-gke-sp", cidr = "10.10.0.0/20", pods_cidr = "10.20.0.0/16", services_cidr = "10.30.0.0/20" }
    psa_range  = { address = "10.40.0.0", prefix_length = 16 }
  }
}
