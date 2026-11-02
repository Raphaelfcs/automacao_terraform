output "function_arn" {
  description = "ARN da função agendadora."
  value       = module.function.function_arn
}

output "schedule_arns" {
  description = "ARNs das agendas start/stop."
  value       = { for k, s in aws_scheduler_schedule.this : k => s.arn }
}
