variable "project_id" {
  type = string
}

variable "policy_name" {
  description = "Nome da política do Cloud Armor (referenciado no GCPBackendPolicy)."
  type        = string
  default     = "armor-lab"
}

variable "ip_name" {
  description = "Nome do IP global (referenciado no Gateway)."
  type        = string
  default     = "ip-lab"
}

variable "waf_rules" {
  description = "Regras WAF pré-configuradas (OWASP) com a prioridade de cada uma."
  type        = map(number)
}

variable "waf_preview" {
  description = "true = só registra no log, sem bloquear (bom para calibrar)."
  type        = bool
  default     = false
}

variable "rate_limit" {
  description = "Requisições por minuto por IP antes do banimento temporário."
  type        = number
  default     = 60
}

variable "allowed_country" {
  description = "Código do país permitido (ex.: BR). Vazio = sem regra geográfica."
  type        = string
  default     = ""
}

variable "enable_https" {
  description = "Cria certificado gerenciado para <IP>.nip.io."
  type        = bool
  default     = false
}
