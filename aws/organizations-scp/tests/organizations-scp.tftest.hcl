# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "aws" {
  mock_resource "aws_organizations_organizational_unit" {
    defaults = {
      id  = "ou-ab12-34cdef56"
      arn = "arn:aws:organizations::123456789012:ou/o-abcd123456/ou-ab12-34cdef56"
    }
  }
  mock_resource "aws_organizations_policy" {
    defaults = {
      id  = "p-examplepolicy1"
      arn = "arn:aws:organizations::123456789012:policy/o-abcd123456/service_control_policy/p-examplepolicy1"
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
      id  = "o-abcd123456"
      arn = "arn:aws:organizations::123456789012:organization/o-abcd123456"
      roots = [{ id = "r-ab12", arn = "arn:aws:organizations::123456789012:root/o-abcd123456/r-ab12", name = "Root", policy_types = [
        { type = "SERVICE_CONTROL_POLICY", status = "ENABLED" },
        { type = "RESOURCE_CONTROL_POLICY", status = "ENABLED" },
        { type = "TAG_POLICY", status = "ENABLED" },
      ] }]
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

run "exemplo_landing_zone" {
  command = apply

  variables {
    allowed_regions        = ["sa-east-1", "us-east-1"]
    required_tags          = ["CentroCusto", "Ambiente", "Dono"]
    create_tag_enforcement = ["CentroCusto"]
    attach_target          = ["Workloads", "Sandbox"]
    enable_rcp             = true
    tags                   = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "rcp_perimetro_de_dados" {
  command = plan

  variables {
    attach_target        = ["root"]
    enable_rcp           = true
    rcp_trusted_accounts = ["210987654321"]
  }

  assert {
    condition     = length(aws_organizations_policy.rcp) == 2
    error_message = "Esperadas duas RCPs: perímetro de identidade e TLS obrigatório."
  }

  assert {
    condition     = alltrue([for p in aws_organizations_policy.rcp : p.type == "RESOURCE_CONTROL_POLICY"])
    error_message = "As RCPs precisam ser do tipo RESOURCE_CONTROL_POLICY."
  }

  assert {
    condition     = jsondecode(aws_organizations_policy.rcp["rcp-perimetro-de-identidade"].content).Statement[0].Condition.StringNotEqualsIfExists["aws:PrincipalOrgID"] == "o-abcd123456"
    error_message = "O perímetro de identidade precisa usar o ID da própria organização."
  }

  assert {
    condition     = contains(jsondecode(aws_organizations_policy.rcp["rcp-perimetro-de-identidade"].content).Statement[0].Condition.StringNotEqualsIfExists["aws:PrincipalAccount"], "210987654321")
    error_message = "A conta confiável declarada precisa entrar na exceção da RCP."
  }

  assert {
    condition     = length(aws_organizations_policy_attachment.rcp) == 2
    error_message = "Cada RCP deve ser anexada uma vez à raiz."
  }
}

run "rcp_desligada_por_padrao" {
  command = plan

  assert {
    condition     = length(aws_organizations_policy.rcp) == 0
    error_message = "Sem enable_rcp, nenhuma RCP pode ser criada."
  }
}

run "rcp_exige_tipo_habilitado_na_raiz" {
  command = plan

  variables {
    enable_rcp = true
  }

  override_data {
    target = data.aws_organizations_organization.this
    values = {
      id    = "o-abcd123456"
      arn   = "arn:aws:organizations::123456789012:organization/o-abcd123456"
      roots = [{ id = "r-ab12", arn = "arn:aws:organizations::123456789012:root/o-abcd123456/r-ab12", name = "Root", policy_types = [{ type = "SERVICE_CONTROL_POLICY", status = "ENABLED" }] }]
    }
  }

  expect_failures = [aws_organizations_policy.rcp]
}

run "rcp_rejeita_conta_invalida" {
  command = plan

  variables {
    enable_rcp           = true
    rcp_trusted_accounts = ["parceiro"]
  }

  expect_failures = [var.rcp_trusted_accounts]
}
