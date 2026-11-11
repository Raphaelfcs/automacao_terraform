# Firestore em modo nativo com CMEK, recuperação point-in-time (7 dias), proteção contra exclusão,
# backups agendados e índices compostos declarados. Concorrência otimista: combina com escritas
# condicionais (precondição de updateTime), sem transações longas travando documentos.

resource "google_firestore_database" "this" {
  project                           = var.project_id
  name                              = var.database_name
  location_id                       = var.location
  type                              = "FIRESTORE_NATIVE"
  concurrency_mode                  = "OPTIMISTIC"
  app_engine_integration_mode       = "DISABLED"
  point_in_time_recovery_enablement = var.point_in_time_recovery ? "POINT_IN_TIME_RECOVERY_ENABLED" : "POINT_IN_TIME_RECOVERY_DISABLED"
  delete_protection_state           = var.delete_protection ? "DELETE_PROTECTION_ENABLED" : "DELETE_PROTECTION_DISABLED"
  deletion_policy                   = var.delete_protection ? "ABANDON" : "DELETE"

  dynamic "cmek_config" {
    for_each = var.kms_key_id == null ? [] : [1]
    content {
      kms_key_name = var.kms_key_id
    }
  }
}

resource "google_firestore_index" "this" {
  for_each = var.composite_indexes

  project    = var.project_id
  database   = google_firestore_database.this.name
  collection = each.value.collection

  dynamic "fields" {
    for_each = each.value.fields
    content {
      field_path = fields.value.path
      order      = fields.value.order
    }
  }
}

resource "google_firestore_backup_schedule" "diario" {
  count = var.daily_backup_retention_days == null ? 0 : 1

  project   = var.project_id
  database  = google_firestore_database.this.name
  retention = "${var.daily_backup_retention_days * 86400}s"

  daily_recurrence {}
}
