variable "domain_name" {
  description = "Nome principal do certificado."
  type        = string
}

variable "subject_alternative_names" {
  description = "Nomes adicionais."
  type        = list(string)
  default     = []
}

variable "zone_id" {
  description = "Zona do Route 53 onde ficam os registros de validação."
  type        = string
}

variable "key_algorithm" {
  description = "RSA_2048 ou EC_prime256v1."
  type        = string
  default     = "RSA_2048"
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
