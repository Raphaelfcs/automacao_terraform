# Testes de plano/apply com providers simulados (terraform test, sem credenciais).

mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/demo-teto-mensal-budgets-action"
    }
  }
  mock_resource "aws_organizations_policy" {
    defaults = {
      id  = "p-examplepolicy1"
      arn = "arn:aws:organizations::123456789012:policy/o-abcd123456/service_control_policy/p-examplepolicy1"
    }
  }
  mock_data "aws_partition" {
    defaults = {
      partition  = "aws"
      dns_suffix = "amazonaws.com"
    }
  }
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:user/teste"
    }
  }
}

run "exemplo_teto_organizacao" {
  command = apply

  variables {
    name              = "demo-teto-mensal"
    limit_usd         = 450
    alert_emails      = ["finops@example.com"]
    freeze_target_ids = ["ou-ab12-22222222", "ou-ab12-55555555"]
  }

  assert {
    condition     = aws_budgets_budget.this.limit_amount == "450.00"
    error_message = "Teto formatado com duas casas decimais."
  }

  assert {
    condition     = length(aws_budgets_budget_action.freeze) == 1
    error_message = "Com alvos informados, a ação de congelamento deveria existir."
  }
}

run "so_alertas" {
  command = plan

  variables {
    name         = "demo-teto-conta"
    limit_usd    = 150
    alert_emails = ["finops@example.com"]
  }

  assert {
    condition     = length(aws_organizations_policy.freeze) == 0 && length(aws_iam_role.budgets_action) == 0
    error_message = "Sem alvos, nada de SCP nem role."
  }
}
