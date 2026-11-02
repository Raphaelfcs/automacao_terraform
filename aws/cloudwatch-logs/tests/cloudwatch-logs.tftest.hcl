# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:user/teste"
    }
  }
  mock_data "aws_region" {
    defaults = {
      name   = "sa-east-1"
      region = "sa-east-1"
    }
  }
  mock_data "aws_partition" {
    defaults = {
      partition  = "aws"
      dns_suffix = "amazonaws.com"
    }
  }
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "exemplo_fluent_bit" {
  command = apply

  variables {
    log_group_name    = "/demo/dev/application"
    retention_days    = 14
    kms_key_arn       = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.sa-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
    oidc_provider_url = "oidc.eks.sa-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
    role_name_prefix  = "demo-teste"
    tags              = { Projeto = "demo", Ambiente = "teste" }
  }
}
