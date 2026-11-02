variable "log_group_name" {
  description = "Nome do log group (ex.: /app/dev/application)."
  type        = string

  validation {
    condition     = startswith(var.log_group_name, "/")
    error_message = "log_group_name deve começar com /."
  }
}

variable "retention_days" {
  description = "Retenção em dias. Zero é proibido: no provider, 0 significa Never expire."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.retention_days)
    error_message = "Use um prazo aceito pelo CloudWatch (nunca 0 = Never expire)."
  }
}

variable "kms_key_arn" {
  description = "Chave KMS do log group (a política da chave deve liberar o CloudWatch Logs)."
  type        = string
  default     = null
}

variable "oidc_provider_arn" {
  description = "ARN do OIDC provider do cluster EKS."
  type        = string
}

variable "oidc_provider_url" {
  description = "Issuer OIDC sem https://."
  type        = string
}

variable "collector_namespace" {
  description = "Namespace do ServiceAccount do coletor."
  type        = string
  default     = "observability"
}

variable "collector_service_account" {
  description = "ServiceAccount do coletor."
  type        = string
  default     = "fluent-bit"
}

variable "role_name_prefix" {
  description = "Prefixo dos nomes de role e políticas."
  type        = string
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
