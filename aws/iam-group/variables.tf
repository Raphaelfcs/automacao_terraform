variable "name" {
  description = "Nome do grupo."
  type        = string
}

variable "path" {
  description = "Path IAM."
  type        = string
  default     = "/"
}

variable "members" {
  description = "Usuários IAM membros (gerenciados por este grupo, de forma exclusiva)."
  type        = list(string)
  default     = []
}

variable "managed_policy_arns" {
  description = "Políticas gerenciadas anexadas."
  type        = list(string)
  default     = []
}

variable "custom_policies" {
  description = "Políticas customizadas: nome -> JSON."
  type        = map(string)
  default     = {}
}

variable "require_mfa" {
  description = "Anexa a política que exige MFA para qualquer ação."
  type        = bool
  default     = true
}
