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
