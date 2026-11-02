# A API no GKE publica no tópico sem chave
resource "google_pubsub_topic_iam_member" "publisher" {
  project = var.project_id
  topic   = google_pubsub_topic.orders.name
  role    = "roles/pubsub.publisher"
  member  = local.ksa_principal
}

# A API lê a senha do banco direto do Secret Manager, também sem chave
resource "google_secret_manager_secret_iam_member" "api_db" {
  project   = var.project_id
  secret_id = var.db_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = local.ksa_principal
}

# ---------- identidades da função
resource "google_service_account" "fn" {
  project      = var.project_id
  account_id   = "sa-notify"
  display_name = "Execução da função ${var.function_name}"
}

resource "google_project_iam_member" "fn" {
  for_each = toset(local.function_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.fn.email}"
}

resource "google_secret_manager_secret_iam_member" "fn_smtp" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.smtp.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.fn.email}"
}

resource "google_service_account" "build" {
  project      = var.project_id
  account_id   = "sa-fn-build"
  display_name = "Build das funções"
}

resource "google_project_iam_member" "build" {
  for_each = toset(local.build_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.build.email}"
}
