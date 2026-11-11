mock_provider "aws" {}

run "cname_de_validacao" {
  command = apply

  variables {
    zone_id = "Z0123456789ABCDEFGHIJ"
    records = {
      gcp-cert = { name = "_acme-challenge.app.example.com.", type = "CNAME", values = ["abc.1.authorize.certificatemanager.goog."] }
    }
  }

  assert {
    condition     = aws_route53_record.this["gcp-cert"].ttl == 300
    error_message = "TTL padrão de 5 minutos."
  }
}

run "tipo_invalido" {
  command = plan

  variables {
    zone_id = "Z1"
    records = { x = { name = "a", type = "SPF", values = ["v"] } }
  }

  expect_failures = [var.records]
}
