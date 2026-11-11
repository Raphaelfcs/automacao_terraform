mock_provider "google" {}

run "documentos_sensiveis" {
  command = apply

  variables {
    project_id      = "demo-dev"
    name            = "demo-dev-documentos"
    kms_key_id      = "projects/demo-dev/locations/southamerica-east1/keyRings/demo-dev/cryptoKeys/dados"
    retention_days  = 30
    cold_after_days = 30
    cors_origins    = ["https://app.example.com"]
  }

  assert {
    condition     = google_storage_bucket.this.public_access_prevention == "enforced" && google_storage_bucket.this.uniform_bucket_level_access
    error_message = "Bucket privado e com IAM uniforme."
  }

  assert {
    condition     = tonumber(google_storage_bucket.this.retention_policy[0].retention_period) == 2592000
    error_message = "Retenção de 30 dias aplicada."
  }

  assert {
    condition     = google_storage_bucket.this.encryption[0].default_kms_key_name == "projects/demo-dev/locations/southamerica-east1/keyRings/demo-dev/cryptoKeys/dados"
    error_message = "CMEK aplicada."
  }
}

run "acesso_publico_recusado" {
  command = plan

  variables {
    project_id   = "demo-dev"
    name         = "x"
    iam_bindings = [{ role = "roles/storage.objectViewer", member = "allUsers" }]
  }

  expect_failures = [var.iam_bindings]
}
