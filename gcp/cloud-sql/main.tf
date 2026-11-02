resource "random_password" "db" {
  length  = 24
  special = false
}

resource "google_sql_database_instance" "pg" {
  project             = var.project_id
  name                = var.instance_name
  region              = var.region
  database_version    = "POSTGRES_16"
  deletion_protection = var.deletion_protection

  settings {
    edition           = "ENTERPRISE"
    tier              = var.tier
    availability_type = var.availability_type
    disk_size         = 10
    user_labels       = var.labels

    ip_configuration {
      ipv4_enabled    = false # sem IP público
      private_network = var.network_id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled    = true
      start_time = "05:00"
    }

    insights_config {
      query_insights_enabled = true
    }
  }
}

resource "google_sql_database" "app" {
  project  = var.project_id
  instance = google_sql_database_instance.pg.name
  name     = var.database
}

resource "google_sql_user" "app" {
  project  = var.project_id
  instance = google_sql_database_instance.pg.name
  name     = var.db_user
  password = random_password.db.result
}

# A senha fica no Secret Manager, com réplica só na região do laboratório
resource "google_secret_manager_secret" "db" {
  project   = var.project_id
  secret_id = local.secret_id
  labels    = var.labels

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db" {
  secret      = google_secret_manager_secret.db.id
  secret_data = random_password.db.result
}
