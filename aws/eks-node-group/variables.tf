variable "cluster_name" {
  description = "Nome do cluster EKS existente."
  type        = string
}

variable "node_role_arn" {
  description = "ARN da role IAM dos nós (output node_role_arn do módulo eks-cluster)."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas padrão dos nós."
  type        = list(string)
}

variable "node_security_group_ids" {
  description = "Security groups anexados às ENIs dos nós via launch template."
  type        = list(string)
}

variable "kms_key_arn" {
  description = "Chave KMS dos volumes EBS. null = chave padrão do EBS."
  type        = string
  default     = null
}

variable "node_groups" {
  description = "Node groups por nome (ex.: system, apps). O nome vira o label role."
  type = map(object({
    instance_types     = list(string)
    desired_size       = number
    min_size           = number
    max_size           = number
    disk_size          = optional(number, 50)
    capacity_type      = optional(string, "ON_DEMAND")
    ami_type           = optional(string, "AL2023_x86_64_STANDARD")
    subnet_ids         = optional(list(string))
    labels             = optional(map(string), {})
    cluster_autoscaler = optional(bool, false)
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
