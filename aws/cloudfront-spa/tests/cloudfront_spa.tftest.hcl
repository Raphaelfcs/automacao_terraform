# Testes de plano com provider simulado (nenhuma chamada à AWS): validam a CONFIGURAÇÃO.
mock_provider "aws" {
  override_during = plan

  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }
  mock_data "aws_caller_identity" {
    defaults = { account_id = "123456789012" }
  }
}

variables {
  name_prefix = "t"
  app_name    = "web"
  dist_path   = "./tests/fixtures/dist"
}

run "padrao_seguro" {
  command = plan

  assert {
    condition     = aws_s3_bucket.this.force_destroy == false
    error_message = "O padrão não pode permitir destruir o bucket com objetos."
  }
  assert {
    condition     = !contains(keys(aws_s3_object.dist), "assets/app.css.map")
    error_message = "Source maps não devem ser publicados por padrão."
  }
  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy
    error_message = "O bucket deve bloquear acesso público."
  }
  assert {
    condition     = length(aws_cloudfront_distribution.this.ordered_cache_behavior) == 0
    error_message = "Sem origem de API não deve haver comportamento /api/*."
  }
}

run "api_por_vpc_origin" {
  command = plan

  variables {
    api_vpc_origin_enabled = true
    api_vpc_origin_arn     = "arn:aws:elasticloadbalancing:sa-east-1:123456789012:loadbalancer/app/api/0123456789abcdef"
    api_vpc_origin_domain  = "internal-api-123.sa-east-1.elb.amazonaws.com"
  }

  assert {
    condition     = length(aws_cloudfront_vpc_origin.api) == 1
    error_message = "VPC origin deve ser criado."
  }
}

run "rejeita_duas_origens" {
  command = plan

  variables {
    api_origin_domain      = "lb.example.com"
    api_vpc_origin_enabled = true
    api_vpc_origin_arn     = "arn:aws:elasticloadbalancing:sa-east-1:123456789012:loadbalancer/app/api/0123456789abcdef"
    api_vpc_origin_domain  = "internal-api-123.sa-east-1.elb.amazonaws.com"
  }

  expect_failures = [var.api_vpc_origin_enabled]
}
