# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "aws" {
  mock_resource "aws_cloudwatch_event_rule" {
    defaults = {
      arn = "arn:aws:events:sa-east-1:123456789012:rule/mock-rule"
    }
  }
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/mock-role"
    }
  }
  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/mock-policy"
    }
  }
  mock_resource "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:sa-east-1:123456789012:log-group:mock"
    }
  }
  mock_resource "aws_apigatewayv2_api" {
    defaults = {
      id            = "abc123defg"
      execution_arn = "arn:aws:execute-api:sa-east-1:123456789012:abc123defg"
      arn           = "arn:aws:apigateway:sa-east-1::/apis/abc123defg"
      api_endpoint  = "https://abc123defg.execute-api.sa-east-1.amazonaws.com"
    }
  }
  mock_resource "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:sa-east-1:123456789012:mock-topic"
    }
  }
  mock_resource "aws_sqs_queue" {
    defaults = {
      arn = "arn:aws:sqs:sa-east-1:123456789012:mock-queue"
      url = "https://sqs.sa-east-1.amazonaws.com/123456789012/mock-queue"
    }
  }
  mock_resource "aws_cloudwatch_event_bus" {
    defaults = {
      arn = "arn:aws:events:sa-east-1:123456789012:event-bus/mock-bus"
    }
  }
  mock_resource "aws_lambda_function" {
    defaults = {
      arn           = "arn:aws:lambda:sa-east-1:123456789012:function:mock"
      invoke_arn    = "arn:aws:apigateway:sa-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:sa-east-1:123456789012:function:mock/invocations"
      qualified_arn = "arn:aws:lambda:sa-east-1:123456789012:function:mock:1"
    }
  }
  mock_resource "aws_cognito_user_pool" {
    defaults = {
      id  = "sa-east-1_AbCdEf123"
      arn = "arn:aws:cognito-idp:sa-east-1:123456789012:userpool/sa-east-1_AbCdEf123"
    }
  }
  mock_resource "aws_launch_template" {
    defaults = {
      id             = "lt-0123456789abcdef0"
      arn            = "arn:aws:ec2:sa-east-1:123456789012:launch-template/lt-0123456789abcdef0"
      latest_version = 1
    }
  }
  mock_resource "aws_msk_configuration" {
    defaults = {
      arn             = "arn:aws:kafka:sa-east-1:123456789012:configuration/mock/11111111-2222-3333-4444-555555555555-1"
      latest_revision = 1
    }
  }
  mock_resource "aws_ec2_transit_gateway" {
    defaults = {
      id  = "tgw-0123456789abcdef0"
      arn = "arn:aws:ec2:sa-east-1:123456789012:transit-gateway/tgw-0123456789abcdef0"
    }
  }
  mock_resource "aws_ram_resource_share" {
    defaults = {
      arn = "arn:aws:ram:sa-east-1:123456789012:resource-share/11111111-2222-3333-4444-555555555555"
    }
  }
  mock_resource "aws_kms_key" {
    defaults = {
      arn    = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
      key_id = "11111111-2222-3333-4444-555555555555"
    }
  }
  mock_resource "aws_backup_vault" {
    defaults = {
      arn = "arn:aws:backup:sa-east-1:123456789012:backup-vault:mock"
    }
  }
  mock_resource "aws_security_group" {
    defaults = {
      id  = "sg-0123456789abcdef0"
      arn = "arn:aws:ec2:sa-east-1:123456789012:security-group/sg-0123456789abcdef0"
    }
  }
  mock_data "aws_vpc" {
    defaults = {
      cidr_block = "10.0.0.0/16"
      arn        = "arn:aws:ec2:sa-east-1:123456789012:vpc/vpc-0123456789abcdef0"
    }
  }
  mock_data "aws_ssoadmin_instances" {
    defaults = {
      arns               = ["arn:aws:sso:::instance/ssoins-0123456789abcdef"]
      identity_store_ids = ["d-0123456789"]
    }
  }
  mock_data "aws_organizations_organization" {
    defaults = {
      id    = "o-abcd123456"
      arn   = "arn:aws:organizations::123456789012:organization/o-abcd123456"
      roots = [{ id = "r-ab12", arn = "arn:aws:organizations::123456789012:root/o-abcd123456/r-ab12", name = "Root", policy_types = [] }]
    }
  }

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
    name_prefix = "demo-teste"
    bucket_name = "demo-iam-inventario-123456789012"
    tags        = { Projeto = "demo", Ambiente = "teste" }
  }
}
