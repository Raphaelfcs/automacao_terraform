variable "name_prefix" {
  description = "Prefixo dos recursos."
  type        = string
}

variable "required_tags" {
  description = "Tags obrigatórias."
  type        = list(string)
  default     = ["CentroCusto", "Ambiente", "Dono"]
}

variable "owner_tag" {
  description = "Tag preenchida automaticamente com quem criou o recurso."
  type        = string
  default     = "CriadoPor"
}

variable "enforce" {
  description = "true = para instâncias EC2 não conformes; false = só notifica."
  type        = bool
  default     = false
}

variable "alert_topic_arn" {
  description = "Tópico SNS dos alertas (módulo sns-topic)."
  type        = string
}

variable "kms_key_arn" {
  description = "Chave KMS do log group e das variáveis da função."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
