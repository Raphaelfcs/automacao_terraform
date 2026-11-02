variable "name_prefix" {
  description = "Prefixo dos recursos."
  type        = string
}

variable "alert_topic_arn" {
  description = "Tópico SNS do relatório."
  type        = string
}

variable "schedule_expression" {
  description = "Agenda do relatório."
  type        = string
  default     = "cron(0 11 ? * MON *)"
}

variable "create_config_rule" {
  description = "Cria a regra gerenciada do Config (exige recorder ativo na conta)."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Chave KMS do log group da função."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
