variable "bucket_name" {
  description = "Nome do bucket (globalmente único)."
  type        = string
}

variable "kms_key_arn" {
  description = "Chave KMS da cifra. null = SSE-S3 (AES256)."
  type        = string
  default     = null
}

variable "versioning" {
  description = "Liga o versionamento (recomendado para dados de negócio; dispensável para artefatos efêmeros)."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Regras de ciclo de vida por id."
  type = map(object({
    prefix                     = optional(string, "")
    transition_days            = optional(number)
    transition_storage_class   = optional(string, "STANDARD_IA")
    expiration_days            = optional(number)
    noncurrent_expiration_days = optional(number)
  }))
  default = {}
}

variable "read_principal_arns" {
  description = "ARNs autorizados a ler o bucket (outras contas/roles)."
  type        = list(string)
  default     = []
}

variable "access_log_bucket" {
  description = "Bucket de destino do server access logging. null = desligado."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Permite destruir com objetos (true só em sandbox)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}

variable "cors_allowed_origins" {
  description = "Origens (https://...) que podem enviar/ler direto do navegador com URL assinada. Vazio = sem CORS."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for o in var.cors_allowed_origins : can(regex("^https://", o))])
    error_message = "cors_allowed_origins aceita apenas origens https://."
  }
}

variable "eventbridge_notifications" {
  description = "Publica eventos do bucket (Object Created etc.) no EventBridge padrão da conta."
  type        = bool
  default     = false
}

variable "object_lock" {
  description = "Retenção padrão com Object Lock (WORM). Só pode ser ligado na criação do bucket. mode: GOVERNANCE ou COMPLIANCE."
  type = object({
    mode = string
    days = number
  })
  default = null

  validation {
    condition     = var.object_lock == null || try(contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock.mode) && var.object_lock.days > 0, false)
    error_message = "object_lock.mode deve ser GOVERNANCE ou COMPLIANCE e days > 0."
  }
}
