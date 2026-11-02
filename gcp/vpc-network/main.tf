resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL" # rotas dinâmicas valem em todas as regiões
}

resource "google_compute_subnetwork" "gke" {
  project                  = var.project_id
  name                     = var.subnet.name
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.subnet.cidr
  private_ip_google_access = true # nós privados falam com as APIs do Google

  secondary_ip_range {
    range_name    = local.pods_range_name
    ip_cidr_range = var.subnet.pods_cidr
  }

  secondary_ip_range {
    range_name    = local.services_range_name
    ip_cidr_range = var.subnet.services_cidr
  }

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.5
  }
}

resource "google_compute_router" "router" {
  project = var.project_id
  name    = "cr-${var.region}"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = "nat-${var.region}"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Private Service Access: Cloud SQL com IP privado dentro da VPC
resource "google_compute_global_address" "psa" {
  project       = var.project_id
  name          = "psa-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.psa_range.address
  prefix_length = var.psa_range.prefix_length
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "psa" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa.name]
}
