variable "namespace" {
  description = "Namespace do Argo CD."
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Versão fixada do chart argo-cd."
  type        = string
  default     = "7.7.11"
}

variable "hostname" {
  description = "Hostname do Ingress do Argo CD. null = sem Ingress (acesso por port-forward)."
  type        = string
  default     = null
}

variable "ingress_class_name" {
  description = "IngressClass do Argo CD (ex.: alb-internal)."
  type        = string
  default     = "alb-internal"
}

variable "server_insecure" {
  description = "TLS terminado no LB (true) ou no próprio argocd-server (false)."
  type        = bool
  default     = true
}

variable "irsa_role_arn" {
  description = "Role IRSA do controller/server (Argo CD hub multi-cluster). null = sem annotation."
  type        = string
  default     = null
}

variable "gitops_repo_url" {
  description = "URL SSH do repositório GitOps."
  type        = string
}

variable "gitops_repo_ssh_key" {
  description = "Chave privada SSH (deploy key somente leitura)."
  type        = string
  sensitive   = true
}

variable "gitops_target_revision" {
  description = "Branch ou tag acompanhada pelo app-of-apps."
  type        = string
  default     = "main"
}

variable "gitops_bootstrap_path" {
  description = "Caminho do app-of-apps DESTE Argo CD no repositório."
  type        = string
  default     = "gitops/bootstrap"
}
