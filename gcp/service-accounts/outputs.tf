output "emails" {
  description = "E-mails por account_id."
  value       = { for k, a in google_service_account.this : k => a.email }
}

output "unique_ids" {
  description = "IDs únicos por account_id (trust policy da AWS)."
  value       = { for k, a in google_service_account.this : k => a.unique_id }
}
