variable "name_prefix" {
  description = "Prefixo dos nomes dos tópicos (ex.: \"app-dev-\")."
  type        = string
  default     = ""
}

variable "topic_names" {
  description = "Nomes dos tópicos."
  type        = list(string)
}

variable "fifo" {
  description = "Cria tópicos FIFO (ordem e deduplicação)."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "Chave KMS dos tópicos (alias/aws/sns não serve para publicadores de outros serviços)."
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "Assinaturas por tópico: lista de { protocol, endpoint, raw_message_delivery, filter_policy }."
  type = map(list(object({
    protocol             = string
    endpoint             = string
    raw_message_delivery = optional(bool, false)
    filter_policy        = optional(any)
  })))
  default = {}
}

variable "publisher_services" {
  description = "Serviços AWS autorizados a publicar (ex.: [\"events.amazonaws.com\", \"cloudwatch.amazonaws.com\"])."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
