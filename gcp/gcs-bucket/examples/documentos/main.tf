# Exemplo "documentos" do módulo gcp/gcs-bucket: Cloud Storage privado para dados sensíveis.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "gcs_bucket" {
  source = "../.."

  project_id      = local.project_id
  name            = "demo-dev-documentos"
  kms_key_id      = "projects/demo-plataforma-dev/locations/southamerica-east1/keyRings/demo-dev/cryptoKeys/dados"
  cold_after_days = 30
  cors_origins    = ["https://app.example.com"]
  labels          = local.labels
}
