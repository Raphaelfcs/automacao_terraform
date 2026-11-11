output "key_id" {
  description = "ID completo da chave (projects/.../cryptoKeys/...), usado como CMEK."
  value       = google_kms_crypto_key.this.id
}

output "key_ring_id" {
  description = "ID do key ring."
  value       = google_kms_key_ring.this.id
}
