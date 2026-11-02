# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

mock_provider "archive" {}

run "exemplo_basico" {
  command = apply

  variables {
    project_id          = "demo-plataforma-dev"
    project_number      = "123456789012"
    region              = "sa-east-1"
    db_secret_id        = "projects/demo-plataforma-dev/secrets/db-password"
    function_source_dir = "src"
    smtp_user           = "notificacoes@example.com"
    smtp_password       = "valor-de-teste"
    mail_to             = "time@example.com"
    labels              = { projeto = "demo", ambiente = "teste" }
  }
}
