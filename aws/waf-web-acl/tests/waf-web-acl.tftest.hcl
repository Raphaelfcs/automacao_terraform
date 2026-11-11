mock_provider "aws" {
  mock_resource "aws_wafv2_web_acl" {
    defaults = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/demo-dev-borda/11111111-2222-3333-4444-555555555555"
    }
  }
  mock_resource "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:aws-waf-logs-demo-dev-borda"
    }
  }
}

run "borda_cloudfront_brasil" {
  command = apply

  variables {
    name                   = "demo-dev-borda"
    allowed_countries      = ["BR"]
    rate_limit_per_5min    = 500
    managed_rule_overrides = { AWSManagedRulesCommonRuleSet = ["SizeRestrictions_BODY"] }
  }

  assert {
    condition     = length(aws_wafv2_web_acl.this.rule) == 5
    error_message = "3 grupos gerenciados + limite por IP + geografia."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this[0].name == "aws-waf-logs-demo-dev-borda"
    error_message = "Log group do WAF precisa do prefixo aws-waf-logs-."
  }

  assert {
    condition     = one([for r in aws_wafv2_web_acl.this.rule : r.statement[0].rate_based_statement[0].limit if r.name == "limite-por-ip"]) == 500
    error_message = "Limite por IP aplicado."
  }
}

run "escopo_invalido" {
  command = plan

  variables {
    name  = "x"
    scope = "GLOBAL"
  }

  expect_failures = [var.scope]
}
