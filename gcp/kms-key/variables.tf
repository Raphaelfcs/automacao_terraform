variable "project_id" {
  description = "Projeto do GCP."
  type        = string
}

variable "location" {
  description = "Região da chave (a mesma dos dados que ela cifra)."
  type        = string
  default     = "southamerica-east1"
}

variable "key_ring_name" {
  description = "Nome do key ring."
  type        = string
}

variable "key_name" {
  description = "Nome da chave."
  type        = string
}

variable "rotation_period" {
  description = "Rotação automática (segundos com sufixo s). Padrão: 90 dias."
  type        = string
  default     = "7776000s"
}

variable "protection_level" {
  description = "SOFTWARE ou HSM (HSM custa mais por versão de chave e por operação)."
  type        = string
  default     = "SOFTWARE"

  validation {
    condition     = contains(["SOFTWARE", "HSM"], var.protection_level)
    error_message = "protection_level deve ser SOFTWARE ou HSM."
  }
}

variable "encrypter_decrypter_members" {
  description = "Membros que cifram/decifram com a chave (ex.: serviceAccount:service-123@gs-project-accounts.iam.gserviceaccount.com)."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels aplicados."
  type        = map(string)
  default     = {}
}
