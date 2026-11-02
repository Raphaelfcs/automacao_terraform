# Azure SQL: servidor lógico com administrador Entra ID (sem SQL auth), TDE com chave do
# cliente opcional, auditoria para Log Analytics, acesso público desligado e bancos
# declarados por mapa (SKU, tamanho, redundância de zona, retenção de backup).

resource "azurerm_mssql_server" "this" {
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.public_network_access

  azuread_administrator {
    login_username              = var.entra_admin_login
    object_id                   = var.entra_admin_object_id
    azuread_authentication_only = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_mssql_server_transparent_data_encryption" "this" {
  count = var.tde_key_vault_key_id == null ? 0 : 1

  server_id        = azurerm_mssql_server.this.id
  key_vault_key_id = var.tde_key_vault_key_id
}

resource "azurerm_mssql_database" "this" {
  for_each = var.databases

  name           = each.key
  server_id      = azurerm_mssql_server.this.id
  sku_name       = each.value.sku_name
  max_size_gb    = each.value.max_size_gb
  zone_redundant = each.value.zone_redundant
  collation      = "SQL_Latin1_General_CP1_CI_AS"

  short_term_retention_policy {
    retention_days = each.value.backup_retention_days
  }

  long_term_retention_policy {
    weekly_retention  = each.value.ltr_weekly
    monthly_retention = each.value.ltr_monthly
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_mssql_server_extended_auditing_policy" "this" {
  count = var.log_analytics_workspace_id == null ? 0 : 1

  server_id              = azurerm_mssql_server.this.id
  log_monitoring_enabled = true
}

resource "azurerm_monitor_diagnostic_setting" "audit" {
  count = var.log_analytics_workspace_id == null ? 0 : 1

  name                       = "auditoria-sql"
  target_resource_id         = "${azurerm_mssql_server.this.id}/databases/master"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }
}
