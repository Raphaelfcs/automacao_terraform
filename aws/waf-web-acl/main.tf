# Web ACL do AWS WAF para CloudFront (crie com provider em us-east-1) ou recursos regionais:
# grupos gerenciados da AWS (OWASP comum, entradas maliciosas conhecidas, reputação de IP),
# limite de requisições por IP, bloqueio geográfico opcional e logs com retenção definida.

resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = "Edge protection for ${var.name}" # o WAF só aceita ASCII na descrição
  scope       = var.scope

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = local.managed
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        dynamic "count" {
          for_each = var.count_only ? [1] : []
          content {}
        }
        dynamic "none" {
          for_each = var.count_only ? [] : [1]
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          vendor_name = "AWS"
          name        = rule.value.name

          dynamic "rule_action_override" {
            for_each = lookup(var.managed_rule_overrides, rule.value.name, [])
            content {
              name = rule_action_override.value
              action_to_use {
                count {}
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "limite-por-ip"
    priority = 100

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit_per_5min
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-limite-por-ip"
      sampled_requests_enabled   = true
    }
  }

  dynamic "rule" {
    for_each = length(var.allowed_countries) > 0 ? [1] : []
    content {
      name     = "somente-paises-permitidos"
      priority = 90

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            geo_match_statement {
              country_codes = var.allowed_countries
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.name}-geo"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# O nome do log group precisa começar com aws-waf-logs-.
resource "aws_cloudwatch_log_group" "this" {
  count             = var.log_retention_days == null ? 0 : 1
  name              = "aws-waf-logs-${var.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  tags              = var.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count                   = var.log_retention_days == null ? 0 : 1
  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [aws_cloudwatch_log_group.this[0].arn]

  # Não grava o token de acesso nos logs.
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }
}
