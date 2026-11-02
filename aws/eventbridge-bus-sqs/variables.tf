variable "name_prefix" {
  description = "Prefixo dos recursos (ex.: app-stg)."
  type        = string
}

variable "bus_name" {
  description = "Nome do barramento (sem o prefixo)."
  type        = string
  default     = "integracao"
}

variable "queue_name" {
  description = "Nome da fila de destino (sem o prefixo)."
  type        = string
}

variable "event_sources" {
  description = "Valores de source aceitos (ex.: [\"parceiro.pedidos\"])."
  type        = list(string)
}

variable "detail_types" {
  description = "detail-type aceitos. Vazio = qualquer um do source."
  type        = list(string)
  default     = []
}

variable "producer_principal_arns" {
  description = "Roles da conta produtora autorizadas a publicar no barramento. Vazio = só a própria conta."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "Chave KMS da fila e da DLQ. A política da chave deve liberar events.amazonaws.com para a regra (output rule_arn)."
  type        = string
}

variable "consumer_role_name" {
  description = "Role do consumidor que recebe a política de leitura. null = nenhuma."
  type        = string
  default     = null
}

variable "archive_retention_days" {
  description = "Retenção do archive para replay. 0 desliga."
  type        = number
  default     = 30
}

variable "queue_retention_seconds" {
  description = "Retenção da fila (máx. 14 dias)."
  type        = number
  default     = 1209600
}

variable "visibility_timeout_seconds" {
  description = "Visibilidade padrão; o consumidor estende enquanto processa."
  type        = number
  default     = 120
}

variable "max_receive_count" {
  description = "Entregas antes da DLQ."
  type        = number
  default     = 10
}

variable "alarm_visible_threshold" {
  description = "Mensagens visíveis por 15 min que indicam consumidor parado."
  type        = number
  default     = 500
}

variable "alarm_age_seconds" {
  description = "Idade máxima aceitável da mensagem mais antiga."
  type        = number
  default     = 14400
}

variable "alarm_actions" {
  description = "Destinos dos alarmes (ex.: tópico SNS)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags comuns."
  type        = map(string)
  default     = {}
}
