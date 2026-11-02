# Conta de serviço própria dos nós (em vez da conta padrão do Compute Engine)
resource "google_service_account" "nodes" {
  project      = var.project_id
  account_id   = "sa-gke-nodes"
  display_name = "Nós do ${var.cluster_name}"
}

resource "google_project_iam_member" "nodes" {
  for_each = toset(local.node_sa_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.nodes.email}"
}
