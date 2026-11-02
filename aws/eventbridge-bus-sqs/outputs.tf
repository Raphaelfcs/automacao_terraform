output "event_bus_arn" {
  description = "ARN do barramento — alvo da regra na conta produtora."
  value       = aws_cloudwatch_event_bus.this.arn
}

output "rule_arn" {
  description = "ARN da regra (informe em event_rule_arns do módulo kms-key)."
  value       = aws_cloudwatch_event_rule.this.arn
}

output "queue_url" {
  description = "URL da fila."
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "ARN da fila."
  value       = aws_sqs_queue.this.arn
}

output "dlq_arn" {
  description = "ARN da DLQ."
  value       = aws_sqs_queue.dlq.arn
}
