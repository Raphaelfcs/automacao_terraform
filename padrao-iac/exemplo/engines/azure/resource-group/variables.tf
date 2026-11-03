variable "projeto" {
  description = "Nome curto do projeto (vai no nome do resource group)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{3,30}$", var.projeto))
    error_message = "Use 3 a 30 caracteres: letras minúsculas, números e hífen."
  }
}

variable "ambiente" {
  description = "dev, hml, prd, dr ou sandbox."
  type        = string
  validation {
    condition     = contains(["dev", "hml", "prd", "dr", "sandbox"], var.ambiente)
    error_message = "Ambiente inválido."
  }
}

variable "location" {
  description = "Região do Azure."
  type        = string
  default     = "brazilsouth"
}

variable "bloquear_exclusao" {
  description = "Cria um lock CanNotDelete (padrão em prd e dr)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags adicionais (as obrigatórias são aplicadas pela engine)."
  type        = map(string)
  default     = {}
}
