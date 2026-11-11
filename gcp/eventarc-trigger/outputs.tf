output "trigger_ids" {
  description = "IDs dos gatilhos."
  value       = { for k, t in google_eventarc_trigger.this : k => t.id }
}

output "service_account_email" {
  description = "Conta de serviço dos gatilhos."
  value       = google_service_account.gatilho.email
}
