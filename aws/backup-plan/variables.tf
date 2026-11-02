variable "name_prefix" {
  description = "Prefixo dos recursos."
  type        = string
}

variable "kms_key_arn" {
  description = "Chave KMS do vault."
  type        = string
}

variable "timezone" {
  description = "Fuso das expressões cron."
  type        = string
  default     = "America/Sao_Paulo"
}

variable "rules" {
  description = "Regras do plano por nome."
  type = map(object({
    schedule                = string
    delete_after_days       = number
    cold_storage_after_days = optional(number)
    continuous              = optional(bool, false)
  }))
  default = {
    diario  = { schedule = "cron(0 3 * * ? *)", delete_after_days = 35 }
    semanal = { schedule = "cron(0 4 ? * SUN *)", delete_after_days = 90 }
    mensal  = { schedule = "cron(0 5 1 * ? *)", delete_after_days = 365, cold_storage_after_days = 30 }
  }
}

variable "selection_tag_key" {
  description = "Tag que inclui o recurso no plano."
  type        = string
  default     = "Backup"
}

variable "selection_tag_value" {
  description = "Valor da tag de seleção."
  type        = string
  default     = "true"
}

variable "copy_destination_vault_arn" {
  description = "Vault de destino para cópia (outra região/conta, DR). null = sem cópia."
  type        = string
  default     = null
}

variable "vault_lock" {
  description = "Vault Lock (modo governance enquanto changeable_for_days não expira; depois compliance/imutável)."
  type = object({
    min_retention_days  = number
    max_retention_days  = number
    changeable_for_days = optional(number, 3)
  })
  default = null
}

variable "vault_admin_role_arns" {
  description = "Roles que podem apagar recovery points (o resto é negado)."
  type        = list(string)
  default     = []
}

variable "notification_topic_arn" {
  description = "Tópico SNS para falhas de backup/cópia."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
