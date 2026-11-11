variable "role_name" {
  description = "Nome da role."
  type        = string
}

variable "google_service_account_ids" {
  description = "IDs únicos (numéricos, 21 dígitos) das contas de serviço do GCP que podem assumir a role."
  type        = list(string)

  validation {
    condition     = length(var.google_service_account_ids) > 0 && alltrue([for i in var.google_service_account_ids : can(regex("^[0-9]{21}$", i))])
    error_message = "Use o unique_id (21 dígitos) da conta de serviço, não o e-mail."
  }
}

variable "audience" {
  description = "Audiência que o workload pede no ID token (vira o claim aud; o AWS compara como oaud)."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "policy_json" {
  description = "Política inline com o mínimo que o workload precisa."
  type        = string
}

variable "max_session_duration" {
  description = "Duração máxima da sessão em segundos."
  type        = number
  default     = 3600
}

variable "permissions_boundary_arn" {
  description = "Permissions boundary da role (opcional)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
