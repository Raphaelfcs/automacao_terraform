output "project_id" {
  value      = google_project.lab.project_id
  depends_on = [google_project_service.apis]
}

output "project_number" {
  value = google_project.lab.number
}

output "folder" {
  value = local.folder_id
}
