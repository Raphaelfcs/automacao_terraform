output "action_group_id" {
  description = "ID do Action Group."
  value       = azurerm_monitor_action_group.this.id
}

output "alert_ids" {
  description = "Mapa alerta|alvo -> ID."
  value       = { for k, a in azurerm_monitor_metric_alert.this : k => a.id }
}
