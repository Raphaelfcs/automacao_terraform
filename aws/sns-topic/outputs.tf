output "topic_arns" {
  description = "Mapa nome -> ARN do tópico."
  value       = { for k, t in aws_sns_topic.this : k => t.arn }
}
