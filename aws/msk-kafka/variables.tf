variable "name_prefix" {
  description = "Prefixo aplicado aos recursos de mensageria."
  type        = string
}

variable "vpc_id" {
  description = "VPC onde os brokers vivem."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas dos brokers, uma por AZ."
  type        = list(string)
}

variable "ingress_security_groups" {
  description = "Security groups autorizados a produzir/consumir: nome estático (chave) -> id (valor)."
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "Chave KMS para os volumes dos brokers e o log group."
  type        = string
}

variable "kafka_version" {
  description = "Versão do Kafka gerenciado (ex.: 3.7.x)."
  type        = string
}

variable "broker_instance_type" {
  description = "Tipo de instância dos brokers (ex.: kafka.t3.small em dev, kafka.m7g.large em produção)."
  type        = string
}

variable "broker_count" {
  description = "Número desejado de brokers (ajustado para múltiplo do número de subnets)."
  type        = number
  default     = 3
}

variable "broker_volume_size" {
  description = "Volume EBS por broker, em GB."
  type        = number
  default     = 100
}

variable "default_partitions" {
  description = "Partições padrão de novos tópicos."
  type        = number
  default     = 3
}

variable "log_retention_hours" {
  description = "Retenção padrão das mensagens em horas."
  type        = number
  default     = 168
}

variable "log_retention_days" {
  description = "Retenção dos logs de broker no CloudWatch."
  type        = number
  default     = 14
}

variable "enhanced_monitoring" {
  description = "DEFAULT, PER_BROKER, PER_TOPIC_PER_BROKER ou PER_TOPIC_PER_PARTITION."
  type        = string
  default     = "DEFAULT"
}

variable "client_topic_prefix" {
  description = "Prefixo de tópicos/grupos liberado na política de cliente (\"\" = todos)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
