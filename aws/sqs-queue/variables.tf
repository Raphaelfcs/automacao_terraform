variable "name_prefix" {
  description = "Prefixo dos nomes das filas."
  type        = string
  default     = ""
}

variable "queues" {
  description = "Nomes das filas."
  type        = list(string)
}

variable "fifo" {
  description = "Cria filas FIFO."
  type        = bool
  default     = false
}

variable "enable_dead_letter" {
  description = "Cria uma DLQ por fila."
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "Entregas antes de mover para a DLQ."
  type        = number
  default     = 5
}

variable "kms_key_arn" {
  description = "Chave KMS. null = SSE gerenciada pelo SQS."
  type        = string
  default     = null
}

variable "visibility_timeout_seconds" {
  description = "Timeout de visibilidade (>= timeout do consumidor Lambda x 6 é a recomendação)."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Retenção das mensagens."
  type        = number
  default     = 345600
}

variable "max_message_size" {
  description = "Tamanho máximo da mensagem em bytes."
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "Atraso de entrega."
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "Long polling (20 reduz chamadas vazias e custo)."
  type        = number
  default     = 20
}

variable "allowed_source_arns" {
  description = "ARNs de tópicos SNS / regras EventBridge / buckets autorizados a enviar."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
