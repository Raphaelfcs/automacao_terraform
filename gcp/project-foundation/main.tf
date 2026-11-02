resource "google_folder" "lab" {
  count        = local.has_org ? 1 : 0
  display_name = var.folder_name
  parent       = "organizations/${var.org_id}"
}

resource "google_project" "lab" {
  project_id          = var.project_id
  name                = var.project_name
  billing_account     = var.billing_account
  folder_id           = local.folder_id
  labels              = var.labels
  auto_create_network = false
  deletion_policy     = "DELETE" # laboratório: permite terraform destroy
}

resource "google_project_service" "apis" {
  for_each           = toset(var.apis)
  project            = google_project.lab.project_id
  service            = each.value
  disable_on_destroy = false
}

# Guarda-corpos herdados por tudo que estiver dentro da pasta
resource "google_org_policy_policy" "boolean" {
  for_each = local.policies
  name     = "${google_folder.lab[0].name}/policies/${each.value}"
  parent   = google_folder.lab[0].name

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}
