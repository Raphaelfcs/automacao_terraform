output "diagnostic_setting_ids" {
  description = "Mapa recurso -> ID do diagnostic setting."
  value       = { for k, d in azurerm_monitor_diagnostic_setting.this : k => d.id }
}
