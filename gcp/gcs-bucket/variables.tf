variable "project_id" {
  description = "Projeto do GCP."
  type        = string
}

variable "name" {
  description = "Nome global do bucket."
  type        = string
}

variable "location" {
  description = "Região do bucket."
  type        = string
  default     = "southamerica-east1"
}

variable "kms_key_id" {
  description = "Chave do Cloud KMS (CMEK). O agente de serviço do Storage precisa de permissão nela."
  type        = string
  default     = null
}

variable "versioning" {
  description = "Mantém versões anteriores dos objetos."
  type        = bool
  default     = true
}

variable "noncurrent_delete_days" {
  description = "Apaga versões antigas depois de N dias. null = mantém."
  type        = number
  default     = 30
}

variable "soft_delete_days" {
  description = "Janela de recuperação de objetos apagados (0 a 90 dias)."
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_days == 0 || (var.soft_delete_days >= 7 && var.soft_delete_days <= 90)
    error_message = "soft_delete_days deve ser 0 ou entre 7 e 90."
  }
}

variable "retention_days" {
  description = "Retenção mínima de cada objeto (WORM). null = sem retenção."
  type        = number
  default     = null
}

variable "lock_retention" {
  description = "Trava a retenção para sempre (irreversível). Use só em produção, depois de validar o prazo."
  type        = bool
  default     = false
}

variable "cold_after_days" {
  description = "Move objetos para classe fria depois de N dias. null = não move."
  type        = number
  default     = null
}

variable "cold_storage_class" {
  description = "Classe fria: NEARLINE (acesso mensal), COLDLINE ou ARCHIVE."
  type        = string
  default     = "NEARLINE"
}

variable "cors_origins" {
  description = "Origens https do app que enviam/baixam com URL assinada. Vazio = sem CORS."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for o in var.cors_origins : can(regex("^https://", o))])
    error_message = "cors_origins aceita apenas https://."
  }
}

variable "iam_bindings" {
  description = "Permissões no bucket: lista de { role, member }."
  type = list(object({
    role   = string
    member = string
  }))
  default = []

  validation {
    condition     = alltrue([for b in var.iam_bindings : !contains(["allUsers", "allAuthenticatedUsers"], b.member)])
    error_message = "Bucket privado: allUsers e allAuthenticatedUsers não são aceitos."
  }
}

variable "force_destroy" {
  description = "Permite destruir com objetos dentro (só para ambientes descartáveis)."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels aplicados."
  type        = map(string)
  default     = {}
}
