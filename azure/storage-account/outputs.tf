output "storage_account_id" {
  description = "ID da storage account."
  value       = azurerm_storage_account.this.id
}

output "primary_blob_endpoint" {
  description = "Endpoint de blob."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "identity_principal_id" {
  description = "Principal da identidade gerenciada."
  value       = azurerm_user_assigned_identity.storage.principal_id
}
