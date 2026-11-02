output "cluster_name" {
  value = google_container_cluster.autopilot.name
}

output "workload_pool" {
  value = "${var.project_id}.svc.id.goog"
}

output "artifact_repo" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}
