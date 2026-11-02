output "site_bucket_name" {
  description = "Nome do bucket do site."
  value       = google_storage_bucket.site.name
}

output "logs_bucket_name" {
  description = "Nome do bucket de logs de acesso (auditoria)."
  value       = google_storage_bucket.logs.name
}

output "site_url" {
  description = "URL pública do site (responde 200 só quando public_access_enabled = true)."
  value       = "https://storage.googleapis.com/${google_storage_bucket.site.name}/${var.main_page_suffix}"
}

output "public_access_enabled" {
  description = "Estado atual do acesso público."
  value       = var.public_access_enabled
}

output "uploaded_files" {
  description = "Arquivos publicados no bucket."
  value       = sort(keys(google_storage_bucket_object.site_files))
}
