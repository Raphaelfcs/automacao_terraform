# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

run "exemplo_basico" {
  command = apply

  variables {
    project_id = "demo-plataforma-dev"
    waf_rules  = { "sqli-v33-stable" = 1000, "xss-v33-stable" = 1001 }
    rate_limit = 60
  }
}
