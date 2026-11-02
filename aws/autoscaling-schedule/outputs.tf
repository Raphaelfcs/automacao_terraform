output "janela" {
  description = "A janela em uma linha, para o output da raiz e para o runbook."
  value       = var.enabled ? "sobe ${var.up_cron} / desce ${var.down_cron} (${var.timezone})" : "24x7 (agendamento desligado)"
}

output "asg_names" {
  description = "ASGs sob agendamento, por chave de pool. Vazio significa que nenhuma acao foi criada."
  value       = local.asg_por_pool
}

output "acoes" {
  description = "Nomes das acoes agendadas criadas. Confira na AWS com `aws autoscaling describe-scheduled-actions --auto-scaling-group-name <asg>`."
  value = concat(
    [for a in aws_autoscaling_schedule.up : a.scheduled_action_name],
    [for a in aws_autoscaling_schedule.down : a.scheduled_action_name],
  )
}
