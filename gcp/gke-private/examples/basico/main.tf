# Exemplo "basico" do módulo gcp/gke-private: GKE privado com Workload Identity.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "gke_private" {
  source = "../.."

  project_id          = "demo-plataforma-dev"
  region              = local.region
  network_self_link   = "projects/demo-plataforma-dev/global/networks/vpc-demo"
  subnet_self_link    = "projects/demo-plataforma-dev/regions/southamerica-east1/subnetworks/sn-gke-sp"
  pods_range_name     = "pods"
  services_range_name = "services"
  maintenance_window  = { start = "2026-01-01T05:00:00Z", end = "2026-01-01T09:00:00Z", recurrence = "FREQ=WEEKLY;BYDAY=SA,SU" }
  labels              = local.labels
}
