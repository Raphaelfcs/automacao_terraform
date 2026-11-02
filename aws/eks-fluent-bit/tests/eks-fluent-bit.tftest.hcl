# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "helm" {}

run "exemplo_basico" {
  command = apply

  variables {
    cluster_name       = "demo-dev"
    region             = "sa-east-1"
    log_group_name     = "/demo/dev/application"
    collector_role_arn = "arn:aws:iam::123456789012:role/demo-dev-log-collector"
  }
}
