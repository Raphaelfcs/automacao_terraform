variable "name_prefix" {
  description = "Namespace dos repositórios (<name_prefix>/<servico>). Vazio = sem namespace."
  type        = string
  default     = ""
}

variable "repository_names" {
  description = "Nomes dos repositórios — um por serviço containerizado."
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "MUTABLE ou IMMUTABLE. Em produção prefira IMMUTABLE (tag nunca é sobrescrita)."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability deve ser MUTABLE ou IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Escaneia vulnerabilidades a cada push."
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Permite destruir o repositório mesmo com imagens (use true só em sandbox)."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "Chave KMS para cifrar as camadas. null = AES256 gerenciado pela AWS."
  type        = string
  default     = null
}

variable "max_image_count" {
  description = "Quantas imagens manter por repositório antes de expirar as antigas."
  type        = number
  default     = 30
}

variable "release_tag_prefixes" {
  description = "Prefixos de tag de release (ex.: [\"v\"]). Vazio = conta todas as imagens."
  type        = list(string)
  default     = []
}

variable "untagged_expiration_days" {
  description = "Dias até expirar imagens sem tag."
  type        = number
  default     = 7
}

variable "pull_principal_arns" {
  description = "ARNs (contas ou roles) autorizados a puxar imagens entre contas."
  type        = list(string)
  default     = []
}

variable "push_principal_arns" {
  description = "ARNs autorizados a publicar imagens (role do pipeline)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags aplicadas a todos os repositórios."
  type        = map(string)
  default     = {}
}
