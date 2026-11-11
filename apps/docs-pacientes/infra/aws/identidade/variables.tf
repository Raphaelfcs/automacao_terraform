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
  description = "Região AWS."
  type        = string
  default     = "sa-east-1"
}

variable "mfa_pacientes" {
  description = "MFA dos pacientes: OPTIONAL (o paciente ativa no app autenticador) ou ON (obrigatório)."
  type        = string
  default     = "OPTIONAL"
}
