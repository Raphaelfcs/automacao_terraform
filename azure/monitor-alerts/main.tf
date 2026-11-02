# Alertas do Azure Monitor: Action Group (e-mail, webhook, SMS) e alertas de métrica
# aplicados a N recursos-alvo (VMs, bancos, Key Vault, storage), com severidade, janela e
# frequência por alerta. Consolida os antigos módulos "monitor-action-group", "vm cpu avg",
# "keyvault monitor" e "database monitor".

resource "azurerm_monitor_action_group" "this" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name

  dynamic "email_receiver" {
    for_each = toset(var.emails)
    content {
      name                    = replace(email_receiver.value, "/[@.]/", "-")
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.webhooks
    content {
      name                    = webhook_receiver.key
      service_uri             = webhook_receiver.value
      use_common_alert_schema = true
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "this" {
  for_each = local.alert_targets

  name                = "${each.value.alert}-${each.value.target_name}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.target_id]
  description         = each.value.description
  severity            = each.value.severity
  frequency           = each.value.frequency
  window_size         = each.value.window_size
  auto_mitigate       = true

  criteria {
    metric_namespace = each.value.metric_namespace
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }

  tags = var.tags
}
