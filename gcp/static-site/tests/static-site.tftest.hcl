# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

run "exemplo_devel" {
  command = apply

  variables {
    project_id  = "demo-plataforma-dev"
    environment = "devel"
    app_name    = "site"
  }
}
