# Exemplo "storage-e-firestore" do módulo gcp/eventarc-trigger: Eventarc para Cloud Run privado.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "eventarc_trigger" {
  source = "../.."

  project_id              = local.project_id
  cloud_run_service       = "demo-dev-eventos"
  service_account_id      = "demo-dev-eventarc"
  grant_storage_publisher = true
  triggers = {
    objeto-criado = { filters = { type = "google.cloud.storage.object.v1.finalized", bucket = "demo-dev-documentos" }, path = "/eventos/gcs" }
  }
  labels = local.labels
}
