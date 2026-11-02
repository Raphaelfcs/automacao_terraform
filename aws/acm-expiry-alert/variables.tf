variable "name_prefix" {
  description = "Prefixo dos recursos."
  type        = string
}

variable "alert_topic_arn" {
  description = "Tópico SNS (a política deve permitir events.amazonaws.com e cloudwatch.amazonaws.com)."
  type        = string
}

variable "certificate_arns" {
  description = "Certificados monitorados por alarme de DaysToExpiry (opcional)."
  type        = list(string)
  default     = []
}

variable "days_threshold" {
  description = "Dias mínimos antes da expiração para o alarme."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
