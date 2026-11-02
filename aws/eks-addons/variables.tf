variable "cluster_name" {
  description = "Nome do cluster EKS — usado no autoDiscovery do autoscaler e no LBC"
  type        = string
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
}

variable "vpc_id" {
  description = "VPC do cluster — o AWS LBC precisa dela para descobrir subnets"
  type        = string
}

variable "cluster_autoscaler_role_arn" {
  description = "ARN da role IRSA do cluster-autoscaler"
  type        = string
}

variable "aws_lbc_role_arn" {
  description = "ARN da role IRSA do AWS Load Balancer Controller"
  type        = string
}

variable "external_secrets_role_arn" {
  description = "ARN da role IRSA do External Secrets Operator"
  type        = string
}

variable "cluster_autoscaler_chart_version" {
  description = "Versão do chart cluster-autoscaler (o app deve casar com o minor do cluster)."
  type        = string
  default     = "9.43.2"
}

variable "aws_lbc_chart_version" {
  description = "Versão do chart aws-load-balancer-controller."
  type        = string
  default     = "1.10.1"
}

variable "metrics_server_chart_version" {
  description = "Versão do chart metrics-server."
  type        = string
  default     = "3.12.2"
}

variable "external_secrets_chart_version" {
  description = "Versão pinada do chart external-secrets — 2.8.0 serve CRDs em apiVersion v1"
  type        = string
  default     = "2.8.0"
}

variable "helm_release_atomic" {
  description = "atomic + cleanup_on_fail nos releases. Com false, release que falha fica `failed` na revision 1 e o apply seguinte exige `helm uninstall` manual — mas o estado parcial fica inspecionável, que é o que se quer num cluster novo"
  type        = bool
  default     = false
}
