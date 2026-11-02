# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "helm" {}

mock_provider "kubernetes" {}

mock_provider "kubectl" {}

run "exemplo_basico" {
  command = apply

  variables {
    cluster_name                = "demo-dev"
    aws_region                  = "sa-east-1"
    vpc_id                      = "vpc-0123456789abcdef0"
    cluster_autoscaler_role_arn = "arn:aws:iam::123456789012:role/demo-dev-cluster-autoscaler"
    aws_lbc_role_arn            = "arn:aws:iam::123456789012:role/demo-dev-aws-lbc"
    external_secrets_role_arn   = "arn:aws:iam::123456789012:role/demo-dev-external-secrets"
  }
}
