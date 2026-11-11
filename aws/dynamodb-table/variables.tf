variable "name" {
  description = "Nome da tabela."
  type        = string
}

variable "hash_key" {
  description = "Chave de partição."
  type        = string
  default     = "pk"
}

variable "range_key" {
  description = "Chave de ordenação (null = sem)."
  type        = string
  default     = "sk"
}

variable "attribute_types" {
  description = "Tipo dos atributos de chave que não são string: nome -> S, N ou B."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for t in values(var.attribute_types) : contains(["S", "N", "B"], t)])
    error_message = "attribute_types aceita S, N ou B."
  }
}

variable "global_secondary_indexes" {
  description = "Índices globais: nome -> { hash_key, range_key, projection_type }."
  type = map(object({
    hash_key        = string
    range_key       = optional(string)
    projection_type = optional(string, "ALL")
  }))
  default = {}
}

variable "stream_view_type" {
  description = "Liga o stream (NEW_AND_OLD_IMAGES, NEW_IMAGE, OLD_IMAGE, KEYS_ONLY). null = sem stream."
  type        = string
  default     = null

  validation {
    condition     = var.stream_view_type == null || contains(["NEW_AND_OLD_IMAGES", "NEW_IMAGE", "OLD_IMAGE", "KEYS_ONLY"], coalesce(var.stream_view_type, "x"))
    error_message = "stream_view_type inválido."
  }
}

variable "kms_key_arn" {
  description = "Chave KMS do cliente para cifrar a tabela."
  type        = string
}

variable "point_in_time_recovery" {
  description = "Recuperação para qualquer segundo dos últimos 35 dias."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Impede excluir a tabela por engano (desligue só para destruir de propósito)."
  type        = bool
  default     = true
}

variable "ttl_attribute" {
  description = "Atributo de expiração (epoch em segundos). null = sem TTL."
  type        = string
  default     = null
}

variable "table_class" {
  description = "STANDARD ou STANDARD_INFREQUENT_ACCESS (armazenamento mais barato, leitura/escrita mais cara)."
  type        = string
  default     = "STANDARD"
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
