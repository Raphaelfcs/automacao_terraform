output "name" {
  description = "Nome do serviço."
  value       = google_cloud_run_v2_service.this.name
}

output "uri" {
  description = "URL do serviço (só responde conforme o ingress)."
  value       = google_cloud_run_v2_service.this.uri
}

output "service_account_email" {
  description = "E-mail da conta de serviço."
  value       = local.sa_email
}

output "service_account_unique_id" {
  description = "ID único da conta de serviço criada aqui (usado em trust policy da AWS); null se a conta veio de fora."
  value       = try(google_service_account.this[0].unique_id, null)
}

output "neg_id" {
  description = "ID do NEG serverless (null se não criado)."
  value       = try(google_compute_region_network_endpoint_group.this[0].id, null)
}
