output "cluster_name" {
  description = "Nome do cluster EKS."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint da API do cluster."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "CA do cluster (base64) para os providers kubernetes/helm."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "SG gerenciado pelo EKS — origem das regras de ingress da camada de dados."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_role_arn" {
  description = "ARN da role IAM dos nós."
  value       = aws_iam_role.node.arn
}

output "oidc_provider_arn" {
  description = "ARN do OIDC provider — principal federado das roles IRSA."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  description = "Issuer OIDC sem https://, como aparece na condição sub da trust policy."
  value       = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}
