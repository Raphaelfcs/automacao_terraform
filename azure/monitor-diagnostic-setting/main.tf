# Diagnostic settings em lote: envia logs e métricas de N recursos para um Log Analytics
# workspace (e/ou storage account de arquivamento). As categorias disponíveis são lidas
# do próprio recurso (data source), evitando listas fixas que quebram entre tipos.

data "azurerm_monitor_diagnostic_categories" "this" {
  for_each = toset(var.target_resource_ids)

  resource_id = each.value
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = toset(var.target_resource_ids)

  name                       = var.name
  target_resource_id         = each.value
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.archive_storage_account_id

  dynamic "enabled_log" {
    for_each = length(var.log_categories) > 0 ? toset(var.log_categories) : toset(data.azurerm_monitor_diagnostic_categories.this[each.key].log_category_types)
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = var.enable_metrics ? toset(data.azurerm_monitor_diagnostic_categories.this[each.key].metrics) : toset([])
    content {
      category = enabled_metric.value
    }
  }
}
