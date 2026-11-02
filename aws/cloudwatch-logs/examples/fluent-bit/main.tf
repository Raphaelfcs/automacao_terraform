# Exemplo "fluent-bit" do módulo aws/cloudwatch-logs: Log group de aplicação + IRSA do coletor.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "cloudwatch_logs" {
  source = "../.."

  log_group_name    = "/demo/dev/application"
  retention_days    = 14
  kms_key_arn       = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.sa-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
  oidc_provider_url = "oidc.eks.sa-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
  role_name_prefix  = local.name_prefix
  tags              = local.tags
}
