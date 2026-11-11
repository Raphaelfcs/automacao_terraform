output "credential_config" {
  description = "JSON external_account para a google-auth (sem segredo). Passe ao workload por variável de ambiente."
  value       = jsonencode(local.credential_config)
}

output "service_account_email" {
  description = "Conta de serviço assumida pelos workloads da AWS."
  value       = google_service_account.this.email
}

output "provider_name" {
  description = "Nome completo do provedor (audience)."
  value       = google_iam_workload_identity_pool_provider.aws.name
}
