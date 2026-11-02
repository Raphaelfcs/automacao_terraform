locals {
  # Addons gerenciados padrão. eks-pod-identity-agent sustenta o EKS Pod Identity
  # (alternativa ao IRSA); o OIDC provider abaixo continua disponível para IRSA.
  managed_addons = toset(var.managed_addons)
}
