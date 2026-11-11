variable "project_id" {
  description = "Projeto do GCP."
  type        = string
}

variable "database_name" {
  description = "Nome do banco. \"(default)\" usa a cota gratuita diária do Firestore."
  type        = string
  default     = "(default)"
}

variable "location" {
  description = "Região do banco (não muda depois de criado)."
  type        = string
  default     = "southamerica-east1"
}

variable "kms_key_id" {
  description = "Chave do Cloud KMS (CMEK), na mesma região. O agente de serviço do Firestore precisa de permissão nela."
  type        = string
  default     = null
}

variable "point_in_time_recovery" {
  description = "Leitura de qualquer instante dos últimos 7 dias."
  type        = bool
  default     = true
}

variable "delete_protection" {
  description = "Impede excluir o banco (e abandona em vez de apagar no destroy)."
  type        = bool
  default     = true
}

variable "daily_backup_retention_days" {
  description = "Backup diário retido por N dias (máximo 98). null = sem backup agendado."
  type        = number
  default     = 14

  validation {
    condition     = var.daily_backup_retention_days == null || try(var.daily_backup_retention_days >= 1 && var.daily_backup_retention_days <= 98, false)
    error_message = "daily_backup_retention_days entre 1 e 98."
  }
}

variable "composite_indexes" {
  description = "Índices compostos: nome -> { collection, fields = [{ path, order }] }."
  type = map(object({
    collection = string
    fields = list(object({
      path  = string
      order = optional(string, "ASCENDING")
    }))
  }))
  default = {}
}
