mock_provider "aws" {
  mock_resource "aws_acm_certificate" {
    defaults = {
      arn = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-2222-3333-4444-555555555555"
    }
  }
}

run "certificado_cloudfront" {
  command = plan

  variables {
    domain_name = "app.example.com"
    zone_id     = "Z0123456789ABCDEFGHIJ"
  }

  assert {
    condition     = aws_acm_certificate.this.validation_method == "DNS"
    error_message = "Validação por DNS."
  }

  assert {
    condition     = keys(aws_route53_record.validacao) == ["app.example.com"]
    error_message = "Um registro de validação por nome, com chave conhecida no plano."
  }
}
