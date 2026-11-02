output "event_rule_arn" {
  description = "ARN da regra do EventBridge."
  value       = aws_cloudwatch_event_rule.expiring.arn
}
