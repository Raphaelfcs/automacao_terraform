resource "google_pubsub_topic" "orders" {
  project                    = var.project_id
  name                       = var.topic_name
  labels                     = var.labels
  message_retention_duration = "86400s"
}

# ---------- segredo do SMTP
resource "google_secret_manager_secret" "smtp" {
  project   = var.project_id
  secret_id = "smtp-password"
  labels    = var.labels

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "smtp" {
  secret      = google_secret_manager_secret.smtp.id
  secret_data = var.smtp_password
}

# ---------- código da função
resource "google_storage_bucket" "src" {
  project                     = var.project_id
  name                        = "${var.project_id}-fn-src"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true
  labels                      = var.labels
}

data "archive_file" "fn" {
  type        = "zip"
  source_dir  = var.function_source_dir
  output_path = "${path.module}/.build/${var.function_name}.zip"
}

resource "google_storage_bucket_object" "fn" {
  name   = "${var.function_name}-${data.archive_file.fn.output_md5}.zip"
  bucket = google_storage_bucket.src.name
  source = data.archive_file.fn.output_path
}

resource "google_cloudfunctions2_function" "notify" {
  project  = var.project_id
  name     = var.function_name
  location = var.region
  labels   = var.labels

  build_config {
    runtime         = "python312"
    entry_point     = "notify_order"
    service_account = google_service_account.build.id
    source {
      storage_source {
        bucket = google_storage_bucket.src.name
        object = google_storage_bucket_object.fn.name
      }
    }
  }

  service_config {
    max_instance_count    = 3
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.fn.email
    environment_variables = {
      SMTP_USER = var.smtp_user
      MAIL_TO   = var.mail_to
    }
    secret_environment_variables {
      key        = "SMTP_PASSWORD"
      project_id = var.project_id
      secret     = google_secret_manager_secret.smtp.secret_id
      version    = "latest"
    }
  }

  event_trigger {
    trigger_region        = var.region
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = google_pubsub_topic.orders.id
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.fn.email
  }

  depends_on = [
    google_secret_manager_secret_version.smtp,
    google_secret_manager_secret_iam_member.fn_smtp,
    google_project_iam_member.build,
  ]
}
