variable "ambiente" {
  description = "Ambiente (dev, hml, prd). Vem de envs/<ambiente>/terraform.tfvars."
  type        = string

  validation {
    condition     = contains(["dev", "hml", "prd"], var.ambiente)
    error_message = "ambiente deve ser dev, hml ou prd."
  }
}

variable "dominio_app" {
  description = "Nome publicado do app (o mesmo nas duas nuvens)."
  type        = string
}

variable "regiao" {
  description = "Região AWS dos dados (residência no Brasil)."
  type        = string
  default     = "sa-east-1"
}

variable "conta_aws" {
  description = "ID da conta AWS do ambiente."
  type        = string
}

variable "object_lock" {
  description = "Retenção WORM dos PDFs (GOVERNANCE permite exceção auditada; COMPLIANCE é irreversível)."
  type = object({
    mode = string
    days = number
  })
}

variable "emails_alerta" {
  description = "E-mails que recebem os alarmes (confirmação por e-mail)."
  type        = list(string)
  default     = []
}

variable "protecao_exclusao" {
  description = "Proteção contra exclusão da tabela."
  type        = bool
  default     = true
}
