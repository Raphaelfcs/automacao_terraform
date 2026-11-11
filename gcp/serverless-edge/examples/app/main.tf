# Exemplo "app" do módulo gcp/serverless-edge: Borda global: LB HTTPS, Cloud Armor e CDN.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "serverless_edge" {
  source = "../.."

  project_id        = local.project_id
  name              = "demo-dev"
  domain            = "app.example.com"
  serverless_neg_id = "projects/demo-plataforma-dev/regions/southamerica-east1/networkEndpointGroups/demo-dev-api-neg"
  web_bucket_name   = "demo-dev-web"
  allowed_countries = ["BR"]
}
