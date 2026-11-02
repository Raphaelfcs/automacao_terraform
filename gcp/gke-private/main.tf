resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.artifact_repo
  format        = "DOCKER"
  description   = "Imagens do laboratório"
  labels        = var.labels
}

resource "google_container_cluster" "autopilot" {
  project             = var.project_id
  name                = var.cluster_name
  location            = var.region # regional: plano de controle em 3 zonas
  enable_autopilot    = true
  network             = var.network_self_link
  subnetwork          = var.subnet_self_link
  deletion_protection = var.deletion_protection
  resource_labels     = var.labels

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true  # nós sem IP público
    enable_private_endpoint = false # laboratório: kubectl pelo Cloud Shell
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(var.authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr
          display_name = cidr_blocks.value.name
        }
      }
    }
  }

  release_channel {
    channel = var.release_channel
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.nodes.email
      oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_window.start
      end_time   = var.maintenance_window.end
      recurrence = var.maintenance_window.recurrence
    }
  }

  depends_on = [google_project_iam_member.nodes]
}
