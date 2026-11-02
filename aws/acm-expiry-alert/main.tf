# Alerta de expiração de certificados sem código: o ACM emite eventos "ACM Certificate
# Approaching Expiration" (45 dias antes por padrão, diariamente até expirar) e o
# Security Hub/Config podem complementar. Substitui a Lambda que varria o ACM e calculava
# os dias restantes. Inclui alarme por métrica DaysToExpiry para certificados importados.

resource "aws_cloudwatch_event_rule" "expiring" {
  name        = "${var.name_prefix}-acm-expirando"
  description = "Certificados ACM proximos da expiracao"
  event_pattern = jsonencode({
    source        = ["aws.acm"]
    "detail-type" = ["ACM Certificate Approaching Expiration", "ACM Certificate Expired", "ACM Certificate Renewal Action Required"]
  })
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.expiring.name
  target_id = "sns"
  arn       = var.alert_topic_arn

  input_transformer {
    input_paths = {
      tipo     = "$.detail-type"
      dias     = "$.detail.DaysToExpiry"
      conta    = "$.account"
      regiao   = "$.region"
      recursos = "$.resources"
    }
    input_template = "\"[ACM] <tipo> - conta <conta> (<regiao>) - dias restantes: <dias> - <recursos>\""
  }
}

# Alarme por certificado (útil para importados, que o ACM não renova).
resource "aws_cloudwatch_metric_alarm" "days_to_expiry" {
  for_each = toset(var.certificate_arns)

  alarm_name          = "${var.name_prefix}-acm-${substr(sha1(each.value), 0, 8)}"
  alarm_description   = "Certificado ${each.value} expira em menos de ${var.days_threshold} dias"
  namespace           = "AWS/CertificateManager"
  metric_name         = "DaysToExpiry"
  dimensions          = { CertificateArn = each.value }
  statistic           = "Minimum"
  period              = 86400
  evaluation_periods  = 1
  threshold           = var.days_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  alarm_actions       = [var.alert_topic_arn]
  tags                = var.tags
}
