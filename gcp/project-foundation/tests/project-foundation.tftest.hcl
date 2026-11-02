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
    project_id       = "demo-plataforma-dev"
    project_name     = "Demo Plataforma"
    billing_account  = "000000-000000-000000"
    apis             = ["compute.googleapis.com", "container.googleapis.com", "sqladmin.googleapis.com"]
    boolean_policies = ["compute.skipDefaultNetworkCreation", "iam.disableServiceAccountKeyCreation", "storage.uniformBucketLevelAccess"]
    labels           = { projeto = "demo", ambiente = "teste" }
  }
}
