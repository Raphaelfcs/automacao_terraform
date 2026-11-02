# -----------------------------------------------------------------------------
# Bucket de logs de acesso (auditoria) — NUNCA público
# https://cloud.google.com/storage/docs/access-logs
# -----------------------------------------------------------------------------
resource "google_storage_bucket" "logs" {
  project       = var.project_id
  name          = local.logs_bucket_name
  location      = var.location
  storage_class = "STANDARD"
  labels        = local.labels
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = var.log_retention_days
    }
    action {
      type = "Delete"
    }
  }

  # remove versões antigas (não-correntes) após 7 dias
  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 7
      with_state                 = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }
}

# -----------------------------------------------------------------------------
# Bucket do site estático
# https://cloud.google.com/storage/docs/hosting-static-website
# -----------------------------------------------------------------------------
resource "google_storage_bucket" "site" {
  project       = var.project_id
  name          = local.site_bucket_name
  location      = var.location
  storage_class = "STANDARD"
  labels        = local.labels
  force_destroy = var.force_destroy

  uniform_bucket_level_access = true
  # Fechado = "enforced" (bloqueia qualquer acesso público). Aberto = "inherited".
  public_access_prevention = var.public_access_enabled ? "inherited" : "enforced"

  website {
    main_page_suffix = var.main_page_suffix
    not_found_page   = var.not_found_page
  }

  versioning {
    enabled = var.enable_versioning
  }

  logging {
    log_bucket        = google_storage_bucket.logs.name
    log_object_prefix = local.log_object_prefix
  }

  depends_on = [google_storage_bucket_iam_member.logs_writer]
}

# -----------------------------------------------------------------------------
# Deploy da aplicação: upload dos arquivos do build (opcional)
# -----------------------------------------------------------------------------
resource "google_storage_bucket_object" "site_files" {
  for_each = local.site_files

  bucket        = google_storage_bucket.site.name
  name          = each.key
  source        = "${var.site_source_dir}/${each.key}"
  content_type  = lookup(local.mime_types, lower(regex("[^.]*$", each.key)), "application/octet-stream")
  cache_control = endswith(each.key, ".html") || endswith(each.key, ".json") ? "no-cache, max-age=0" : "public, max-age=3600"
}
