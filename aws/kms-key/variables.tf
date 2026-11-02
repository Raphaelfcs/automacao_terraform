variable "name_prefix" {
  description = "Prefixo aplicado ao nome e ao alias da chave (alias/<name_prefix>)."
  type        = string
}

variable "description" {
  description = "Descrição da chave. Vazio = '<name_prefix> - criptografia em repouso'."
  type        = string
  default     = null
}

variable "deletion_window_in_days" {
  description = "Janela de exclusão da chave (7 a 30). Em dev use 7 para teardown rápido; em produção, 30."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days deve estar entre 7 e 30."
  }
}

variable "rotation_period_in_days" {
  description = "Período da rotação automática (90 a 2560 dias)."
  type        = number
  default     = 365
}

variable "multi_region" {
  description = "Cria a chave como multi-região (necessário para réplicas cifradas entre regiões)."
  type        = bool
  default     = false
}

variable "key_administrator_arns" {
  description = "ARNs de roles que administram a chave (sem permissão de uso). Vazio = só a conta."
  type        = list(string)
  default     = []
}

variable "allow_cloudwatch_logs" {
  description = "Permite que o CloudWatch Logs desta conta/região cifre log groups com a chave."
  type        = bool
  default     = true
}

variable "event_rule_arns" {
  description = "ARNs das regras do EventBridge que entregam em filas/tópicos cifrados com esta chave. O ARN é determinístico (arn:aws:events:<regiao>:<conta>:rule/<barramento>/<regra>), então pode ser composto sem ciclo de dependência."
  type        = list(string)
  default     = []
}

variable "service_principals" {
  description = "Principais de serviço adicionais que usam a chave em nome próprio (ex.: [\"sns.amazonaws.com\"])."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags aplicadas à chave."
  type        = map(string)
  default     = {}
}
