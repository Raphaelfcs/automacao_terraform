output "queue_urls" {
  description = "Mapa nome -> URL."
  value       = { for k, q in aws_sqs_queue.this : k => q.id }
}

output "queue_arns" {
  description = "Mapa nome -> ARN."
  value       = { for k, q in aws_sqs_queue.this : k => q.arn }
}

output "dlq_arns" {
  description = "Mapa nome -> ARN da DLQ."
  value       = { for k, q in aws_sqs_queue.dlq : k => q.arn }
}
