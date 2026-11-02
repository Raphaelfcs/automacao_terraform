# O grupo de analytics do Cloud Storage precisa gravar os objetos de log
resource "google_storage_bucket_iam_member" "logs_writer" {
  bucket = google_storage_bucket.logs.name
  role   = "roles/storage.objectCreator"
  member = "group:cloud-storage-analytics@google.com"
}

# Leitura pública SOMENTE durante a janela de execução/teste
resource "google_storage_bucket_iam_member" "public_read" {
  count = var.public_access_enabled ? 1 : 0

  bucket = google_storage_bucket.site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
