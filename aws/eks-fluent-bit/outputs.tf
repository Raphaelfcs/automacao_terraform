output "release_name" {
  description = "Nome do release Helm."
  value       = helm_release.fluent_bit.name
}

output "release_status" {
  description = "Status do release."
  value       = helm_release.fluent_bit.status
}
