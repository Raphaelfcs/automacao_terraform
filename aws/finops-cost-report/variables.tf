variable "name_prefix" {
  description = "Prefixo dos recursos."
  type        = string
}

variable "bucket_name" {
  description = "Bucket dos CSVs (criado pelo módulo)."
  type        = string
}

variable "alert_topic_arn" {
  description = "Tópico SNS do resumo (assine o e-mail do time FinOps nele)."
  type        = string
}

variable "schedule_expression" {
  description = "Agenda (UTC no EventBridge clássico): 11h UTC = 8h em São Paulo."
  type        = string
  default     = "cron(0 11 * * ? *)"
}

variable "cost_allocation_tag" {
  description = "Tag de alocação de custos ativada no Billing (ex.: CentroCusto). Vazio = só por serviço."
  type        = string
  default     = ""
}

variable "top_n" {
  description = "Quantos itens listar no resumo."
  type        = number
  default     = 10
}

variable "report_retention_days" {
  description = "Retenção dos CSVs no S3."
  type        = number
  default     = 400
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
