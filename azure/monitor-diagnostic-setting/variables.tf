variable "name" {
  description = "Nome do diagnostic setting."
  type        = string
  default     = "envio-log-analytics"
}

variable "target_resource_ids" {
  description = "IDs dos recursos monitorados."
  type        = list(string)
}

variable "log_analytics_workspace_id" {
  description = "Workspace de destino."
  type        = string
}

variable "archive_storage_account_id" {
  description = "Storage account de arquivamento (opcional)."
  type        = string
  default     = null
}

variable "log_categories" {
  description = "Categorias de log. Vazio = todas as suportadas pelo recurso."
  type        = list(string)
  default     = []
}

variable "enable_metrics" {
  description = "Envia também as métricas (AllMetrics)."
  type        = bool
  default     = true
}
