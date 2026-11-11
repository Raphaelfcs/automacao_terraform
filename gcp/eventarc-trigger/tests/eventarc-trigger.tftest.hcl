mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
  mock_resource "google_service_account" {
    defaults = {
      email = "demo-dev-eventos@demo-dev.iam.gserviceaccount.com"
    }
  }
}

run "storage_e_firestore" {
  command = apply

  variables {
    project_id              = "demo-dev"
    cloud_run_service       = "demo-dev-eventos"
    service_account_id      = "demo-dev-eventarc"
    grant_storage_publisher = true
    triggers = {
      objeto-criado = {
        filters = { type = "google.cloud.storage.object.v1.finalized", bucket = "demo-dev-documentos" }
        path    = "/eventos/gcs"
      }
      item-gravado = {
        filters       = { type = "google.cloud.firestore.document.v1.written", database = "(default)" }
        path_patterns = { document = "itens/{id}" }
        path          = "/eventos/firestore"
      }
    }
  }

  assert {
    condition     = google_project_iam_member.gcs_publica[0].member == "serviceAccount:service-123456789012@gs-project-accounts.iam.gserviceaccount.com"
    error_message = "Agente do Storage publica eventos."
  }

  assert {
    condition     = google_eventarc_trigger.this["item-gravado"].event_data_content_type == "application/json"
    error_message = "Firestore entrega em JSON para o serviço decodificar sem protobuf."
  }
}

run "gatilho_sem_tipo" {
  command = plan

  variables {
    project_id         = "demo-dev"
    cloud_run_service  = "x"
    service_account_id = "demo-dev-eventarc"
    triggers           = { a = { filters = { bucket = "b" }, path = "/x" } }
  }

  expect_failures = [var.triggers]
}
