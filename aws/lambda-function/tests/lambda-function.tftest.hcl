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

mock_provider "archive" {}

run "exemplo_agendada" {
  command = apply

  variables {
    function_name       = "demo-dev-relatorio"
    source_dir          = "tests/fixtures/src"
    schedule_expression = "rate(1 day)"
    environment         = { NIVEL_LOG = "INFO" }
    tags                = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "exemplo_vpc_sqs" {
  command = apply

  variables {
    function_name   = "demo-dev-processa"
    source_dir      = "tests/fixtures/src"
    vpc             = { subnet_ids = ["subnet-0aaa1111bbbb2222c"], security_group_ids = ["sg-0123456789abcdef0"] }
    sqs_trigger_arn = "arn:aws:sqs:sa-east-1:123456789012:demo-dev-pedidos"
    tracing         = true
    tags            = { Projeto = "demo", Ambiente = "teste" }
  }
}
