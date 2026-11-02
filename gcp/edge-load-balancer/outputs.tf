output "ip_address" {
  value = google_compute_global_address.lb.address
}

output "policy_name" {
  value = google_compute_security_policy.armor.name
}

output "https_domain" {
  value = var.enable_https ? local.https_domain : null
}
