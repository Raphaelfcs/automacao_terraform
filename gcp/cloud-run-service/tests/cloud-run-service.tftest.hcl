mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      email     = "demo-dev-api@demo-dev.iam.gserviceaccount.com"
      unique_id = "112233445566778899001"
    }
  }
}

run "api_atras_do_lb" {
  command = apply

  variables {
    project_id            = "demo-dev"
    name                  = "demo-dev-api"
    image                 = "southamerica-east1-docker.pkg.dev/demo-dev/docs/docs-pacientes:abc123"
    service_account_id    = "demo-dev-api"
    invoker_members       = ["allUsers"]
    create_serverless_neg = true
    env                   = { NUVEM = "gcp", MODO = "api" }
  }

  assert {
    condition     = google_cloud_run_v2_service.this.ingress == "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
    error_message = "Por padrão só o Load Balancer chega ao serviço."
  }

  assert {
    condition     = google_cloud_run_v2_service.this.template[0].scaling[0].min_instance_count == 0
    error_message = "Escala a zero por padrão."
  }

  assert {
    condition     = output.service_account_unique_id == "112233445566778899001" && output.neg_id != null
    error_message = "Saídas para federação e LB."
  }
}

run "ingress_invalido" {
  command = plan

  variables {
    project_id         = "demo-dev"
    name               = "x"
    image              = "x"
    service_account_id = "demo-dev-x"
    ingress            = "PUBLICO"
  }

  expect_failures = [var.ingress]
}

run "conta_de_servico_existente" {
  command = plan

  variables {
    project_id            = "demo-dev"
    name                  = "demo-dev-eventos"
    image                 = "southamerica-east1-docker.pkg.dev/demo-dev/docs/docs-pacientes:abc123"
    service_account_email = "demo-dev-eventos@demo-dev.iam.gserviceaccount.com"
    ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  }

  assert {
    condition     = length(google_service_account.this) == 0 && google_cloud_run_v2_service.this.template[0].service_account == "demo-dev-eventos@demo-dev.iam.gserviceaccount.com"
    error_message = "Usa a conta existente sem criar outra."
  }
}

run "sem_conta_de_servico" {
  command = plan

  variables {
    project_id = "demo-dev"
    name       = "x"
    image      = "x"
  }

  expect_failures = [var.service_account_email]
}
