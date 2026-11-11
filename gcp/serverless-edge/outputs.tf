output "ip_address" {
  description = "IP global do Load Balancer (registro A no DNS)."
  value       = google_compute_global_address.this.address
}

output "dns_authorization_record" {
  description = "Registro CNAME que autoriza o certificado: { name, type, data }."
  value = {
    name = google_certificate_manager_dns_authorization.this.dns_resource_record[0].name
    type = google_certificate_manager_dns_authorization.this.dns_resource_record[0].type
    data = google_certificate_manager_dns_authorization.this.dns_resource_record[0].data
  }
}

output "security_policy_id" {
  description = "Política do Cloud Armor."
  value       = google_compute_security_policy.api.id
}
