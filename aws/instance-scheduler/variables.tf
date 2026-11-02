variable "name_prefix" {
  description = "Prefixo dos recursos."
  type        = string
}

variable "schedule_tag" {
  description = "Chave da tag que marca recursos agendados."
  type        = string
  default     = "Agenda"
}

variable "schedule_value" {
  description = "Valor da tag."
  type        = string
  default     = "horario-comercial"
}

variable "start_cron" {
  description = "Expressão de início (EventBridge Scheduler)."
  type        = string
  default     = "cron(0 7 ? * MON-FRI *)"
}

variable "stop_cron" {
  description = "Expressão de parada."
  type        = string
  default     = "cron(0 20 ? * MON-FRI *)"
}

variable "timezone" {
  description = "Fuso horário das expressões."
  type        = string
  default     = "America/Sao_Paulo"
}

variable "dry_run" {
  description = "Só registra o que faria."
  type        = bool
  default     = false
}

variable "ebs_kms_key_arns" {
  description = "CMKs dos volumes EBS (para o start funcionar com volumes cifrados por CMK)."
  type        = list(string)
  default     = []
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
