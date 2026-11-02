# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

mock_provider "random" {}

run "exemplo_basico" {
  command = apply

  variables {
    project_id = "demo-plataforma-dev"
    region     = "sa-east-1"
    network_id = "projects/demo-plataforma-dev/global/networks/vpc-demo"
    labels     = { projeto = "demo", ambiente = "teste" }
  }
}
