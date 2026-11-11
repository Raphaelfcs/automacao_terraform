# Bucket privado do Cloud Storage para dados sensíveis: acesso uniforme por IAM, prevenção de
# acesso público imposta, CMEK, versionamento, soft delete, retenção opcional (WORM, com trava),
# mudança de classe por idade e CORS só para as origens do app (URL assinada no navegador).

resource "google_storage_bucket" "this" {
  project                     = var.project_id
  name                        = var.name
  location                    = var.location
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = var.force_destroy

  versioning {
    enabled = var.versioning
  }

  dynamic "encryption" {
    for_each = var.kms_key_id == null ? [] : [1]
    content {
      default_kms_key_name = var.kms_key_id
    }
  }

  soft_delete_policy {
    retention_duration_seconds = var.soft_delete_days * 86400
  }

  dynamic "retention_policy" {
    for_each = var.retention_days == null ? [] : [1]
    content {
      retention_period = var.retention_days * 86400
      is_locked        = var.lock_retention
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.cold_after_days == null ? [] : [1]
    content {
      condition {
        age = var.cold_after_days
      }
      action {
        type          = "SetStorageClass"
        storage_class = var.cold_storage_class
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.versioning && var.noncurrent_delete_days != null ? [1] : []
    content {
      condition {
        days_since_noncurrent_time = var.noncurrent_delete_days
        with_state                 = "ARCHIVED"
      }
      action {
        type = "Delete"
      }
    }
  }

  dynamic "cors" {
    for_each = length(var.cors_origins) > 0 ? [1] : []
    content {
      origin          = var.cors_origins
      method          = ["GET", "PUT"]
      response_header = ["Content-Type", "x-goog-content-length-range", "x-goog-meta-origem", "ETag"]
      max_age_seconds = 3000
    }
  }

  labels = var.labels
}

resource "google_storage_bucket_iam_member" "this" {
  for_each = { for b in var.iam_bindings : "${b.role}|${b.member}" => b }
  bucket   = google_storage_bucket.this.name
  role     = each.value.role
  member   = each.value.member
}
