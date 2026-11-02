variable "resource_group_name" {
  description = "Resource group dos alertas."
  type        = string
}

variable "action_group_name" {
  description = "Nome do Action Group."
  type        = string
}

variable "action_group_short_name" {
  description = "Nome curto (até 12 caracteres, aparece em SMS/e-mail)."
  type        = string
}

variable "emails" {
  description = "E-mails notificados."
  type        = list(string)
  default     = []
}

variable "webhooks" {
  description = "Webhooks (ex.: Teams/Slack/ITSM): nome -> URL."
  type        = map(string)
  default     = {}
}

variable "metric_alerts" {
  description = "Alertas de métrica por nome, cada um aplicado a todos os target_ids."
  type = map(object({
    target_ids       = list(string)
    metric_namespace = string
    metric_name      = string
    aggregation      = optional(string, "Average")
    operator         = optional(string, "GreaterThan")
    threshold        = number
    severity         = optional(number, 2)
    frequency        = optional(string, "PT5M")
    window_size      = optional(string, "PT15M")
    description      = optional(string, "")
  }))
  default = {}
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
