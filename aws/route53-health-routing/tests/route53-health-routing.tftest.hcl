mock_provider "aws" {}

run "aws_e_gcp_meio_a_meio" {
  command = apply

  variables {
    zone_id     = "Z0123456789ABCDEFGHIJ"
    record_name = "app.example.com"
    endpoints = {
      aws = { alias = { name = "d111111abcdef8.cloudfront.net", zone_id = "Z2FDTNDATAQYW2" }, health_fqdn = "d111111abcdef8.cloudfront.net" }
      gcp = { ips = ["34.120.0.10"], health_fqdn = "app.example.com", health_ip = "34.120.0.10" }
    }
    alarm_topic_arn = "arn:aws:sns:us-east-1:123456789012:demo-alertas"
  }

  assert {
    condition     = length(aws_route53_health_check.this) == 2 && length(aws_cloudwatch_metric_alarm.endpoint) == 2
    error_message = "Um health check e um alarme por endpoint."
  }

  assert {
    condition     = aws_route53_record.alias["aws"].weighted_routing_policy[0].weight == 50 && aws_route53_record.ips["gcp"].weighted_routing_policy[0].weight == 50
    error_message = "Ativo-ativo: pesos iguais por padrão."
  }

  assert {
    condition     = aws_route53_health_check.this["gcp"].ip_address == "34.120.0.10" && aws_route53_health_check.this["gcp"].enable_sni
    error_message = "Health check do GCP vai no IP com SNI do nome publicado."
  }
}

run "alias_e_ips_juntos_e_recusado" {
  command = plan

  variables {
    zone_id     = "Z1"
    record_name = "app.example.com"
    endpoints = {
      a = { alias = { name = "x", zone_id = "y" }, ips = ["1.1.1.1"], health_fqdn = "x" }
      b = { ips = ["2.2.2.2"], health_fqdn = "x" }
    }
  }

  expect_failures = [var.endpoints]
}
