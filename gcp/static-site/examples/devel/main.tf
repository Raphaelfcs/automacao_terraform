# Exemplo "devel" do módulo gcp/static-site: Site estático em Cloud Storage.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "static_site" {
  source = "../.."

  project_id  = "demo-plataforma-dev"
  environment = "devel"
  app_name    = "site"
}
