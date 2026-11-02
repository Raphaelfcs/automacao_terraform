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

run "exemplo_basico" {
  command = apply

  variables {
    name_prefix             = "demo-teste"
    deletion_window_in_days = 7
    tags                    = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "exemplo_eventbridge_e_sns" {
  command = apply

  variables {
    name_prefix            = "demo-teste"
    event_rule_arns        = ["arn:aws:events:sa-east-1:123456789012:rule/demo-bus/demo-regra"]
    service_principals     = ["sns.amazonaws.com"]
    key_administrator_arns = ["arn:aws:iam::123456789012:role/platform-admin"]
    tags                   = { Projeto = "demo", Ambiente = "teste" }
  }
}
