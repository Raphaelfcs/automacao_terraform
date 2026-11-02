output "namespace" {
  description = "Namespace do Argo CD."
  value       = helm_release.argocd.namespace
}

output "chart_version" {
  description = "Versão do chart instalada."
  value       = helm_release.argocd.version
}

output "bootstrap_path" {
  description = "Caminho do app-of-apps sincronizado."
  value       = var.gitops_bootstrap_path
}
