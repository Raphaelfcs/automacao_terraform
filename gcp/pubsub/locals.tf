locals {
  # Identidade da conta de serviço do Kubernetes no IAM (Workload Identity Federation for GKE)
  ksa_principal = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.k8s_namespace}/sa/${var.k8s_service_account}"

  function_roles = [
    "roles/run.invoker",            # o gatilho do Eventarc chama a função
    "roles/eventarc.eventReceiver", # recebe eventos
    "roles/logging.logWriter",
  ]
  build_roles = [
    "roles/cloudbuild.builds.builder",
    "roles/logging.logWriter",
    "roles/artifactregistry.writer",
    "roles/storage.objectViewer",
  ]
}
