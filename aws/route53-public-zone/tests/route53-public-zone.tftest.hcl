# Testes de plano/apply com providers simulados (terraform test, sem credenciais).

mock_provider "aws" {
  mock_resource "aws_route53_zone" {
    defaults = {
      zone_id      = "Z0123456789ABCDEFGHIJ"
      name_servers = ["ns-1.awsdns-01.org", "ns-2.awsdns-02.co.uk", "ns-3.awsdns-03.com", "ns-4.awsdns-04.net"]
    }
  }
  mock_resource "aws_acm_certificate" {
    defaults = {
      arn = "arn:aws:acm:sa-east-1:123456789012:certificate/11111111-2222-3333-4444-555555555555"
      domain_validation_options = [
        { domain_name = "dev.example.com", resource_record_name = "_abc.dev.example.com.", resource_record_type = "CNAME", resource_record_value = "_xyz.acm-validations.aws." },
        { domain_name = "*.dev.example.com", resource_record_name = "_abc.dev.example.com.", resource_record_type = "CNAME", resource_record_value = "_xyz.acm-validations.aws." },
      ]
    }
  }
}

run "exemplo_zona_com_wildcard" {
  command = apply

  variables {
    zone_name = "dev.example.com"
  }

  assert {
    condition     = length(aws_route53_record.validation) == 1
    error_message = "Domínio e curinga compartilham um único registro de validação."
  }

  assert {
    condition     = length(aws_route53_record.caa) == 1
    error_message = "O registro CAA deveria ser criado por padrão."
  }
}

run "dominio_invalido" {
  command = plan

  variables {
    zone_name = "Dev.Example.com."
  }

  expect_failures = [var.zone_name]
}
