mock_provider "google" {
  mock_resource "google_firestore_database" {
    defaults = {
      name = "(default)"
      id   = "projects/demo-dev/databases/(default)"
    }
  }
}

run "banco_com_indices_e_backup" {
  command = apply

  variables {
    project_id = "demo-dev"
    kms_key_id = "projects/demo-dev/locations/southamerica-east1/keyRings/demo-dev/cryptoKeys/dados"
    composite_indexes = {
      tenant   = { collection = "itens", fields = [{ path = "pk" }, { path = "sk" }] }
      paciente = { collection = "itens", fields = [{ path = "paciente_sub" }, { path = "sk" }] }
    }
  }

  assert {
    condition     = google_firestore_database.this.point_in_time_recovery_enablement == "POINT_IN_TIME_RECOVERY_ENABLED" && google_firestore_database.this.delete_protection_state == "DELETE_PROTECTION_ENABLED"
    error_message = "PITR e proteção contra exclusão ligados."
  }

  assert {
    condition     = google_firestore_backup_schedule.diario[0].retention == "1209600s"
    error_message = "Backup diário de 14 dias."
  }

  assert {
    condition     = length(google_firestore_index.this) == 2
    error_message = "Índices compostos criados."
  }
}

run "retencao_fora_do_limite" {
  command = plan

  variables {
    project_id                  = "demo-dev"
    daily_backup_retention_days = 365
  }

  expect_failures = [var.daily_backup_retention_days]
}
