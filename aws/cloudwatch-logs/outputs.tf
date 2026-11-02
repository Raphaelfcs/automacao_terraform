output "log_group_name" {
  description = "Nome do log group."
  value       = aws_cloudwatch_log_group.application.name
}

output "log_group_arn" {
  description = "ARN do log group."
  value       = aws_cloudwatch_log_group.application.arn
}

output "collector_role_arn" {
  description = "Role IRSA do coletor (anote no ServiceAccount: eks.amazonaws.com/role-arn)."
  value       = aws_iam_role.collector.arn
}

output "reader_policy_arn" {
  description = "Política de leitura para anexar a quem consulta os logs."
  value       = aws_iam_policy.reader.arn
}
