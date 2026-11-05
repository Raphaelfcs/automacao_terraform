# Testes de plano/apply com providers simulados (terraform test, sem credenciais).

mock_provider "aws" {}

run "exemplo_delegar_subdominio" {
  command = apply

  variables {
    parent_zone_id = "Z0123456789ABCDEFGHIJ"
    subdomain      = "dev.example.com"
    name_servers   = ["ns-1.awsdns-01.org", "ns-2.awsdns-02.co.uk", "ns-3.awsdns-03.com", "ns-4.awsdns-04.net"]
  }

  assert {
    condition     = aws_route53_record.delegation.type == "NS"
    error_message = "A delegação é um registro NS."
  }
}

run "poucos_servidores" {
  command = plan

  variables {
    parent_zone_id = "Z0123456789ABCDEFGHIJ"
    subdomain      = "dev.example.com"
    name_servers   = ["ns-1.awsdns-01.org"]
  }

  expect_failures = [var.name_servers]
}
