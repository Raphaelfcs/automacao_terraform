output "ingress_class_name" {
  description = "IngressClass criada pelo chart do AWS LBC e marcada como padrão do cluster"
  value       = "alb-internal"
}

output "cluster_secret_store_name" {
  description = "Nome do ClusterSecretStore do ESO (mesmo nome em todos os clusters)"
  value       = "aws-secretsmanager"
}

output "addon_versions" {
  description = "Versões dos charts instalados"
  value = {
    cluster_autoscaler           = helm_release.cluster_autoscaler.version
    aws_load_balancer_controller = helm_release.aws_load_balancer_controller.version
    metrics_server               = helm_release.metrics_server.version
    external_secrets             = helm_release.external_secrets.version
  }
}
