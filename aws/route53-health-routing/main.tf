# Roteamento DNS ativo-ativo entre nuvens: um nome (ex.: app.example.com) com registros
# ponderados para cada endpoint (CloudFront, IP de load balancer de outra nuvem), cada um com
# health check HTTPS próprio. Endpoint que falha sai da resposta do DNS em ~1 minuto; se todos
# falharem, o Route 53 volta a responder com todos (fail-open), o que evita apagão por health check.

resource "aws_route53_health_check" "this" {
  for_each = var.endpoints

  type              = "HTTPS"
  fqdn              = each.value.health_fqdn
  ip_address        = each.value.health_ip
  port              = 443
  resource_path     = var.health_path
  enable_sni        = true
  request_interval  = 30
  failure_threshold = 3
  measure_latency   = false
  regions           = var.health_regions

  tags = merge(var.tags, { Name = "${var.record_name}-${each.key}" })
}

resource "aws_route53_record" "alias" {
  for_each = { for k, e in var.endpoints : k => e if e.alias != null }

  zone_id         = var.zone_id
  name            = var.record_name
  type            = "A"
  set_identifier  = each.key
  health_check_id = aws_route53_health_check.this[each.key].id

  weighted_routing_policy {
    weight = each.value.weight
  }

  alias {
    name                   = each.value.alias.name
    zone_id                = each.value.alias.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ips" {
  for_each = { for k, e in var.endpoints : k => e if length(e.ips) > 0 }

  zone_id         = var.zone_id
  name            = var.record_name
  type            = "A"
  ttl             = 60
  records         = each.value.ips
  set_identifier  = each.key
  health_check_id = aws_route53_health_check.this[each.key].id

  weighted_routing_policy {
    weight = each.value.weight
  }
}

resource "aws_cloudwatch_metric_alarm" "endpoint" {
  for_each = var.alarm_topic_arn == null ? {} : var.endpoints

  alarm_name          = "${var.record_name}-${each.key}-fora"
  alarm_description   = "Endpoint ${each.key} de ${var.record_name} reprovado no health check: o DNS deixou de mandar tráfego para ele."
  namespace           = "AWS/Route53"
  metric_name         = "HealthCheckStatus"
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 2
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  dimensions          = { HealthCheckId = aws_route53_health_check.this[each.key].id }
  alarm_actions       = [var.alarm_topic_arn]
  ok_actions          = [var.alarm_topic_arn]
  tags                = var.tags
}
