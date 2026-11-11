# Contas de serviço criadas fora dos módulos de computação, para outro estado poder referenciá-las
# antes de o serviço existir (ex.: trust policy da AWS que precisa do ID único). Cada conta recebe só
# os papéis de projeto listados e, opcionalmente, permissão de assinar com a própria identidade.

resource "google_service_account" "this" {
  for_each     = var.accounts
  project      = var.project_id
  account_id   = each.key
  display_name = each.value.display_name
}

resource "google_project_iam_member" "this" {
  for_each = { for p in local.pares : "${p.conta}|${p.papel}" => p }
  project  = var.project_id
  role     = each.value.papel
  member   = "serviceAccount:${google_service_account.this[each.value.conta].email}"
}

resource "google_service_account_iam_member" "auto_assinatura" {
  for_each           = { for k, a in var.accounts : k => a if a.self_sign }
  service_account_id = google_service_account.this[each.key].name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.this[each.key].email}"
}
