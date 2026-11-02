variable "name_prefix" {
  description = "Prefixo dos recursos (compõe os nomes dos buckets; precisa ser globalmente único)."
  type        = string
}

variable "features" {
  description = "Recursos do Textract: FORMS, TABLES, SIGNATURES, LAYOUT."
  type        = list(string)
  default     = ["FORMS", "TABLES"]
}

variable "accepted_suffixes" {
  description = "Extensões processadas."
  type        = list(string)
  default     = [".pdf", ".png", ".jpg", ".jpeg", ".tiff"]
}

variable "input_retention_days" {
  description = "Dias até apagar os documentos de entrada (dados pessoais: retenção mínima)."
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "Chave KMS dos buckets e da função."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
