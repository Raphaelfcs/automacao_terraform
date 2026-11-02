# Exemplo "basico" do módulo gcp/edge-load-balancer: Load Balancer global + Cloud Armor.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "edge_load_balancer" {
  source = "../.."

  project_id = "demo-plataforma-dev"
  waf_rules  = { "sqli-v33-stable" = 1000, "xss-v33-stable" = 1001 }
  rate_limit = 60
}
