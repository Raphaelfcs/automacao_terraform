variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do control plane (ex.: 1.31). Atualize um minor por vez."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas do control plane e dos nós (mínimo duas AZs)."
  type        = list(string)
}

variable "kms_key_arn" {
  description = "Chave KMS do envelope encryption dos secrets e do log group."
  type        = string
}

variable "endpoint_public_access" {
  description = "Liga o endpoint público da API. Produção: false (acesso via VPN/bastion/SSM)."
  type        = bool
  default     = false
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs autorizados no endpoint público (egress do CI e da equipe)."
  type        = list(string)
  default     = []
}

variable "service_ipv4_cidr" {
  description = "Service CIDR do cluster. null = padrão do EKS."
  type        = string
  default     = null
}

variable "authentication_mode" {
  description = "API (recomendado), API_AND_CONFIG_MAP ou CONFIG_MAP."
  type        = string
  default     = "API"
}

variable "bootstrap_creator_admin" {
  description = "Dá admin ao principal que criou o cluster. Prefira false + access_entries."
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "Logs do control plane enviados ao CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "log_retention_days" {
  description = "Retenção dos logs do control plane."
  type        = number
  default     = 30
}

variable "managed_addons" {
  description = "Addons gerenciados instalados no cluster."
  type        = list(string)
  default     = ["vpc-cni", "coredns", "kube-proxy", "eks-pod-identity-agent"]
}

variable "pre_node_addons" {
  description = "Addons criados antes dos node groups (nunca coredns)."
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.pre_node_addons, "coredns")
    error_message = "coredns não pode ser pré-nó: sem nó ele não fica ACTIVE e o apply trava."
  }
}

variable "addon_configuration_values" {
  description = "configuration_values (JSON) por nome de addon."
  type        = map(string)
  default     = {}
}

variable "node_pools" {
  description = "Node groups gerenciados. Separe planos (sistema, apps, dados) com labels e taints."
  type = map(object({
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
    disk_size      = optional(number, 50)
    capacity_type  = optional(string, "ON_DEMAND")
    ami_type       = optional(string, "AL2023_x86_64_STANDARD")
    labels         = optional(map(string), {})
    subnet_ids     = optional(list(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = {}
}

variable "access_entries" {
  description = "Principais com acesso ao cluster. policy: AmazonEKSClusterAdminPolicy, AmazonEKSAdminPolicy, AmazonEKSEditPolicy ou AmazonEKSViewPolicy."
  type = map(object({
    principal_arn = string
    policy        = string
    namespaces    = optional(list(string), [])
  }))
  default = {}
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos do cluster."
  type        = map(string)
  default     = {}
}
