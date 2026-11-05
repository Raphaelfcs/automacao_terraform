# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida o exemplo documentado, o reaproveitamento de contas existentes e a regra do manifesto 4.0.

mock_provider "aws" {
  mock_resource "aws_organizations_organizational_unit" {
    defaults = {
      id  = "ou-ab12-34cdef56"
      arn = "arn:aws:organizations::123456789012:ou/o-abcd123456/ou-ab12-34cdef56"
    }
  }
  mock_resource "aws_organizations_account" {
    defaults = {
      id  = "210987654321"
      arn = "arn:aws:organizations::123456789012:account/o-abcd123456/210987654321"
    }
  }
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/service-role/mock"
    }
  }
  mock_resource "aws_controltower_landing_zone" {
    defaults = {
      arn = "arn:aws:controltower:sa-east-1:123456789012:landingzone/1A2B3C4D5E6F7G8H"
    }
  }
  mock_data "aws_organizations_organization" {
    defaults = {
      id    = "o-abcd123456"
      arn   = "arn:aws:organizations::123456789012:organization/o-abcd123456"
      roots = [{ id = "r-ab12", arn = "arn:aws:organizations::123456789012:root/o-abcd123456/r-ab12", name = "Root", policy_types = [] }]
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
}

run "exemplo_landing_zone" {
  command = apply

  variables {
    governed_regions          = ["sa-east-1", "us-east-1"]
    log_archive_account       = { name = "demo-log-archive", email = "aws+demo-log-archive@example.com" }
    audit_account             = { name = "demo-security-audit", email = "aws+demo-security-audit@example.com" }
    log_retention_days        = 365
    access_log_retention_days = 30
    tags                      = { Projeto = "demo", Ambiente = "teste" }
  }

  assert {
    condition     = length(aws_organizations_account.shared) == 2
    error_message = "As contas Log Archive e Audit deveriam ser criadas."
  }

  assert {
    condition     = output.manifest.backup.enabled == false && output.manifest.config.enabled
    error_message = "Backup deveria vir desligado e Config ligado por padrão."
  }
}

run "contas_existentes" {
  command = plan

  variables {
    governed_regions        = ["sa-east-1"]
    existing_security_ou_id = "ou-ab12-11111111"
    log_archive_account     = { name = "log", email = "log@example.com", id = "111111111111" }
    audit_account           = { name = "audit", email = "audit@example.com", id = "222222222222" }
  }

  assert {
    condition     = length(aws_organizations_account.shared) == 0 && length(aws_organizations_organizational_unit.security) == 0
    error_message = "Com IDs informados, nada deveria ser criado no Organizations."
  }

  assert {
    condition     = output.manifest.securityRoles.accountId == "222222222222"
    error_message = "securityRoles deveria apontar para a conta Audit."
  }
}

run "config_desligado_exige_integracoes_desligadas" {
  command = plan

  variables {
    governed_regions    = ["sa-east-1"]
    log_archive_account = { name = "log", email = "log@example.com" }
    audit_account       = { name = "audit", email = "audit@example.com" }
    enable_config       = false
  }

  expect_failures = [aws_controltower_landing_zone.this]
}
