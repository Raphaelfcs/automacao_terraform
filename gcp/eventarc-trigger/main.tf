# Gatilhos do Eventarc entregando eventos (Cloud Storage, Firestore, Pub/Sub...) a um serviço
# Cloud Run privado. Cria a conta de serviço do gatilho com o mínimo (receber eventos e invocar
# aquele serviço) e, se pedido, a permissão que o agente do Cloud Storage precisa para publicar.

data "google_project" "this" {
  project_id = var.project_id
}

resource "google_service_account" "gatilho" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Eventarc -> ${var.cloud_run_service}"
}

resource "google_project_iam_member" "receber" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.gatilho.email}"
}

resource "google_cloud_run_v2_service_iam_member" "invocar" {
  project  = var.project_id
  location = var.region
  name     = var.cloud_run_service
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.gatilho.email}"
}

# Gatilhos do Cloud Storage publicam via Pub/Sub em nome do agente de serviço do Storage.
resource "google_project_iam_member" "gcs_publica" {
  count   = var.grant_storage_publisher ? 1 : 0
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.this.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_eventarc_trigger" "this" {
  for_each = var.triggers

  project                 = var.project_id
  name                    = each.key
  location                = var.region
  service_account         = google_service_account.gatilho.email
  event_data_content_type = each.value.content_type

  dynamic "matching_criteria" {
    for_each = each.value.filters
    content {
      attribute = matching_criteria.key
      value     = matching_criteria.value
    }
  }

  dynamic "matching_criteria" {
    for_each = each.value.path_patterns
    content {
      attribute = matching_criteria.key
      value     = matching_criteria.value
      operator  = "match-path-pattern"
    }
  }

  destination {
    cloud_run_service {
      service = var.cloud_run_service
      region  = var.region
      path    = each.value.path
    }
  }

  labels = var.labels

  depends_on = [google_project_iam_member.receber, google_cloud_run_v2_service_iam_member.invocar, google_project_iam_member.gcs_publica]
}
