variable "bucket_name" {
  description = "Nome do bucket de estado (ex.: <org>-tfstate-<conta>)."
  type        = string
}

variable "kms_key_arn" {
  description = "Chave KMS do bucket. null = chave gerenciada aws/s3."
  type        = string
  default     = null
}

variable "noncurrent_version_days" {
  description = "Dias de retenção das versões antigas do state."
  type        = number
  default     = 90
}

variable "create_dynamodb_lock_table" {
  description = "Cria tabela DynamoDB de lock (só para Terraform < 1.10)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
