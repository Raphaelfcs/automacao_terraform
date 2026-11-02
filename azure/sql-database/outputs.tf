output "server_id" {
  description = "ID do servidor."
  value       = azurerm_mssql_server.this.id
}

output "server_fqdn" {
  description = "FQDN do servidor."
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_ids" {
  description = "Mapa nome -> ID do banco."
  value       = { for k, d in azurerm_mssql_database.this : k => d.id }
}
