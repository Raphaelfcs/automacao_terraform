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

variable "projeto_gcp" {
  description = "Projeto do GCP do ambiente."
  type        = string
}

variable "regiao_gcp" {
  description = "Região GCP dos dados (residência no Brasil)."
  type        = string
  default     = "southamerica-east1"
}

variable "conta_aws" {
  description = "Conta AWS cujas Lambdas acessam o GCP por federação."
  type        = string
}

variable "retencao_dias" {
  description = "Retenção mínima dos PDFs (WORM). Prontuário: 20 anos (CFM 1.821/2007). null = sem retenção (dev)."
  type        = number
  default     = null
}

variable "travar_retencao" {
  description = "Trava a retenção do bucket (irreversível). Só depois de validar o prazo com o jurídico."
  type        = bool
  default     = false
}

variable "protecao_exclusao" {
  description = "Proteção contra exclusão do banco."
  type        = bool
  default     = true
}
