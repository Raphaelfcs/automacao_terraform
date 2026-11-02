# Exemplo "basico" do módulo gcp/cloud-sql: Cloud SQL privado.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "cloud_sql" {
  source = "../.."

  project_id = "demo-plataforma-dev"
  region     = local.region
  network_id = "projects/demo-plataforma-dev/global/networks/vpc-demo"
  labels     = local.labels
}
