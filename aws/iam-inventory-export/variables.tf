variable "name_prefix" {
  description = "Prefixo dos recursos."
  type        = string
}

variable "bucket_name" {
  description = "Bucket do inventário."
  type        = string
}

variable "schedule_expression" {
  description = "Agenda da exportação."
  type        = string
  default     = "cron(0 6 ? * SUN *)"
}

variable "retention_days" {
  description = "Retenção dos inventários."
  type        = number
  default     = 365
}

variable "kms_key_arn" {
  description = "Chave KMS do bucket e do log group."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
