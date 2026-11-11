# Exemplo "api" do módulo gcp/cloud-run-service: Cloud Run com conta de serviço própria e NEG.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "cloud_run_service" {
  source = "../.."

  project_id            = local.project_id
  name                  = "demo-dev-api"
  image                 = "southamerica-east1-docker.pkg.dev/demo-plataforma-dev/docs/api:1.0.0"
  service_account_id    = "demo-dev-api"
  invoker_members       = ["allUsers"]
  create_serverless_neg = true
  env                   = { NUVEM = "gcp" }
  labels                = local.labels
}
