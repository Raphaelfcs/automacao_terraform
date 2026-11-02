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

run "exemplo_publica" {
  command = apply

  variables {
    name                 = "demo-dev-api"
    lambda_function_name = "demo-dev-processa"
    lambda_invoke_arn    = "arn:aws:apigateway:sa-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:sa-east-1:123456789012:function:demo-dev-processa/invocations"
    tags                 = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "exemplo_jwt_cognito" {
  command = apply

  variables {
    name                 = "demo-dev-api"
    lambda_function_name = "demo-dev-processa"
    lambda_invoke_arn    = "arn:aws:apigateway:sa-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:sa-east-1:123456789012:function:demo-dev-processa/invocations"
    routes               = ["GET /pedidos", "POST /pedidos"]
    jwt_authorizer       = { issuer = "https://cognito-idp.sa-east-1.amazonaws.com/sa-east-1_EXAMPLE", audience = ["1example23456789"] }
    cors_allow_origins   = ["https://app.example.com"]
    tags                 = { Projeto = "demo", Ambiente = "teste" }
  }
}
