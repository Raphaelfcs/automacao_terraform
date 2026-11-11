mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      email     = "demo-dev-api@demo-dev.iam.gserviceaccount.com"
      unique_id = "112233445566778899001"
      name      = "projects/demo-dev/serviceAccounts/demo-dev-api@demo-dev.iam.gserviceaccount.com"
    }
  }
}

run "api_e_eventos" {
  command = apply

  variables {
    project_id = "demo-dev"
    accounts = {
      demo-dev-api     = { display_name = "API", project_roles = ["roles/datastore.user"], self_sign = true }
      demo-dev-eventos = { display_name = "Eventos", project_roles = ["roles/datastore.user", "roles/eventarc.eventReceiver"] }
    }
  }

  assert {
    condition     = length(google_project_iam_member.this) == 3 && length(google_service_account_iam_member.auto_assinatura) == 1
    error_message = "Papéis por conta e auto-assinatura só onde pedida."
  }
}

run "papel_basico_recusado" {
  command = plan

  variables {
    project_id = "demo-dev"
    accounts   = { demo-dev-x = { display_name = "X", project_roles = ["roles/editor"] } }
  }

  expect_failures = [var.accounts]
}
