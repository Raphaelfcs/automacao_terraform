output "id" {
  description = "ID do resource group."
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Nome do resource group."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Região do resource group."
  value       = azurerm_resource_group.this.location
}
