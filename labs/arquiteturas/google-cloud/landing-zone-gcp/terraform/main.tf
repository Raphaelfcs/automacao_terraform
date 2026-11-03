# Automação do lab "Landing zone no Google Cloud".
# Compõe módulos do catálogo; cada módulo continua testado e versionado no próprio diretório.
# Dependências entre módulos são resolvidas pelas saídas (outputs) de um módulo nas entradas do outro.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

variable "smtp_password" {
  type      = string
  sensitive = true
}

module "project_foundation" {
  source = "../../../../../gcp/project-foundation"

  project_id       = "demo-plataforma-dev"
  project_name     = "Demo Plataforma"
  billing_account  = "000000-000000-000000"
  apis             = ["compute.googleapis.com", "container.googleapis.com", "sqladmin.googleapis.com"]
  boolean_policies = ["compute.skipDefaultNetworkCreation", "iam.disableServiceAccountKeyCreation", "storage.uniformBucketLevelAccess"]
  labels           = local.labels
}

module "vpc_network" {
  source = "../../../../../gcp/vpc-network"

  project_id = module.project_foundation.project_id
  region     = local.region
  subnet     = { name = "sn-gke-sp", cidr = "10.10.0.0/20", pods_cidr = "10.20.0.0/16", services_cidr = "10.30.0.0/20" }
  psa_range  = { address = "10.40.0.0", prefix_length = 16 }
}

module "gke_private" {
  source = "../../../../../gcp/gke-private"

  project_id          = module.project_foundation.project_id
  region              = local.region
  network_self_link   = module.vpc_network.network_self_link
  subnet_self_link    = module.vpc_network.subnet_self_link
  pods_range_name     = module.vpc_network.pods_range_name
  services_range_name = module.vpc_network.services_range_name
  maintenance_window  = { start = "2026-01-01T05:00:00Z", end = "2026-01-01T09:00:00Z", recurrence = "FREQ=WEEKLY;BYDAY=SA,SU" }
  labels              = local.labels
}

module "cloud_sql" {
  source = "../../../../../gcp/cloud-sql"

  project_id = module.project_foundation.project_id
  region     = local.region
  network_id = module.vpc_network.network_id
  labels     = local.labels

  depends_on = [module.vpc_network]
}

module "pubsub" {
  source = "../../../../../gcp/pubsub"

  project_id          = module.project_foundation.project_id
  project_number      = module.project_foundation.project_number
  region              = local.region
  db_secret_id        = "projects/demo-plataforma-dev/secrets/db-password"
  function_source_dir = "${path.module}/../../../../../gcp/pubsub/src"
  smtp_user           = "notificacoes@example.com"
  smtp_password       = var.smtp_password
  mail_to             = "time@example.com"
  labels              = local.labels
}

module "edge_load_balancer" {
  source = "../../../../../gcp/edge-load-balancer"

  project_id = module.project_foundation.project_id
  waf_rules  = { "sqli-v33-stable" = 1000, "xss-v33-stable" = 1001 }
  rate_limit = 60
}
