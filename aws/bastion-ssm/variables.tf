variable "environment" {
  description = "Environment name — compõe nomes de recursos (log group, tags)"
  type        = string
}

variable "allowed_environments" {
  description = "Ambientes em que o bastion pode existir (guarda avaliada em lifecycle.precondition)"
  type        = list(string)
  default     = ["dev", "staging"]
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "private_subnet_id" {
  description = "ID de uma subnet privada (a instância nunca fica em subnet pública)"
  type        = string
}

variable "eks_cluster_sg_id" {
  description = "Security group ID do control plane EKS (output cluster_security_group_id do eks-cluster) — recebe regra de ingress standalone deste módulo, sem editar o módulo eks"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instância EC2 do bastion"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "AMI a usar. Se null, resolve a AMI Amazon Linux 2023 mais recente via SSM parameter"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Tamanho do volume raiz em GB"
  type        = number
  default     = 30
}

variable "kms_key_id" {
  description = "CMK para encriptar o volume raiz e o CloudWatch Log Group. Se null, usa a chave gerenciada default do serviço (aws/ebs, aws/logs)"
  type        = string
  default     = null
}

variable "kubectl_version" {
  description = "Versão do kubectl a instalar via dl.k8s.io, pinada. Mantenha dentro da skew policy (±1 minor) do cluster"
  type        = string
  default     = "v1.35.0"
}

variable "awscli_version" {
  description = "Versão do AWS CLI v2 a instalar via instalador oficial (nunca dnf). Nunca inferior a 2.15.10 (primeira versão que gera apiVersion v1beta1 no bloco exec do kubeconfig)"
  type        = string
  default     = "2.36.4"
}

variable "enable_grpcurl" {
  description = "Instala grpcurl (útil para depurar serviços gRPC)"
  type        = bool
  default     = true
}

variable "enable_helm" {
  description = "Instala helm no bootstrap"
  type        = bool
  default     = false
}

variable "enable_k9s" {
  description = "Instala k9s no bootstrap"
  type        = bool
  default     = false
}

variable "enable_stern" {
  description = "Instala stern no bootstrap"
  type        = bool
  default     = false
}

variable "restrict_egress" {
  description = "Quando true, restringe o egress do bastion a um conjunto explícito de portas/SGs em vez de 0.0.0.0/0 all"
  type        = bool
  default     = false
}

variable "eks_access_policy_arn" {
  description = "ARN da EKS access policy associada à role do bastion"
  type        = string
  default     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "manage_session_preferences" {
  description = "Quando true, gerencia o documento singleton SSM-SessionManagerRunShell (afeta toda a conta/região)."
  type        = bool
  default     = false
}

variable "session_log_retention_days" {
  description = "Retenção em dias do CloudWatch Log Group de sessões Session Manager"
  type        = number
  default     = 90
}

variable "rds_security_group_id" {
  description = "Security group do RDS PostgreSQL — usado apenas quando restrict_egress = true (egress 5432)"
  type        = string
  default     = null
}

variable "redis_security_group_id" {
  description = "Security group ID do ElastiCache Redis — usado apenas quando restrict_egress = true"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags a aplicar em todos os recursos deste módulo"
  type        = map(string)
  default     = {}
}
