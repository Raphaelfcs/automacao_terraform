# Serviço Cloud Run (v2) com conta de serviço própria, escala a zero, limites de instância e
# ingress restrito. Para ficar atrás de um Load Balancer global (com Cloud Armor), crie o NEG
# serverless (create_serverless_neg) e use ingress "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER".

resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Cloud Run ${var.name}"
}

resource "google_cloud_run_v2_service" "this" {
  project             = var.project_id
  name                = var.name
  location            = var.region
  ingress             = var.ingress
  deletion_protection = var.deletion_protection

  template {
    service_account                  = google_service_account.this.email
    max_instance_request_concurrency = var.concurrency
    timeout                          = "${var.timeout_seconds}s"
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN2"

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.image

      resources {
        limits            = { cpu = var.cpu, memory = var.memory }
        cpu_idle          = true
        startup_cpu_boost = true
      }

      dynamic "env" {
        for_each = var.env
        content {
          name  = env.key
          value = env.value
        }
      }
    }

    labels = var.labels
  }

  labels = var.labels
}

resource "google_cloud_run_v2_service_iam_member" "invoker" {
  for_each = toset(var.invoker_members)
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  member   = each.value
}

resource "google_project_iam_member" "sa" {
  for_each = toset(var.project_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.this.email}"
}

resource "google_compute_region_network_endpoint_group" "this" {
  count                 = var.create_serverless_neg ? 1 : 0
  project               = var.project_id
  name                  = "${var.name}-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.this.name
  }
}
