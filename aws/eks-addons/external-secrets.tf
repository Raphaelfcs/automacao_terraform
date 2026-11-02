# External Secrets Operator: sincroniza segredos do Secrets Manager para Secrets do
# Kubernetes (credenciais nunca em values/git). Instalado por Terraform, e não por GitOps,
# para evitar ciclo de bootstrap: ele precisa existir antes do primeiro sync que o usa.
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.external_secrets_chart_version
  namespace        = "external-secrets"
  create_namespace = true

  atomic          = true
  cleanup_on_fail = true
  timeout         = 600
  wait            = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.external_secrets_role_arn
  }

  # O controller roda no node group "system", que tem o taint CriticalAddonsOnly. É
  # componente de plataforma, como o resto do que roda lá.
  set {
    name  = "tolerations[0].key"
    value = "CriticalAddonsOnly"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  }

  depends_on = [helm_release.aws_load_balancer_controller]
}

# ClusterSecretStore único por cluster, com o MESMO nome em todos os clusters
# (aws-secretsmanager): um ExternalSecret escrito para um cluster funciona no outro.
#
# apiVersion v1 (não v1beta1): no chart 2.8.0, v1 é a storage version e v1beta1 só é
# servida com crds.unsafeServeV1Beta1=true, que não setamos.
resource "kubectl_manifest" "cluster_secret_store" {
  yaml_body = <<-YAML
    apiVersion: external-secrets.io/v1
    kind: ClusterSecretStore
    metadata:
      name: aws-secretsmanager
    spec:
      provider:
        aws:
          service: SecretsManager
          region: ${var.aws_region}
  YAML

  server_side_apply = true

  depends_on = [helm_release.external_secrets]
}
