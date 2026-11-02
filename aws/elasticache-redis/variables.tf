variable "name_prefix" {
  description = "Prefixo aplicado aos recursos de cache."
  type        = string
}

variable "vpc_id" {
  description = "VPC onde o cluster vive."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas do subnet group."
  type        = list(string)
}

variable "ingress_security_groups" {
  description = "Security groups autorizados na porta do cache: nome estático (chave) -> id (valor)."
  # Chave estática: ids de SG criados no mesmo apply são desconhecidos no plan.
  type    = map(string)
  default = {}
}

variable "kms_key_arn" {
  description = "Chave KMS para criptografia em repouso."
  type        = string
}

variable "engine" {
  description = "valkey (recomendado) ou redis."
  type        = string
  default     = "valkey"

  validation {
    condition     = contains(["valkey", "redis"], var.engine)
    error_message = "engine deve ser valkey ou redis."
  }
}

variable "engine_version" {
  description = "Versão do motor (ex.: 8.0 para Valkey)."
  type        = string
}

variable "node_type" {
  description = "Tipo de nó (ex.: cache.t4g.micro em dev)."
  type        = string
}

variable "port" {
  description = "Porta do cache."
  type        = number
  default     = 6379
}

variable "replica_count" {
  description = "Réplicas de leitura. > 0 liga failover automático e Multi-AZ (produção)."
  type        = number
  default     = 0
}

variable "preferred_cache_cluster_azs" {
  description = "AZs preferidas dos nós, em ordem. null = AWS escolhe."
  type        = list(string)
  default     = null
}

variable "snapshot_retention_limit" {
  description = "Dias de retenção de snapshot (0 desliga)."
  type        = number
  default     = 1
}

variable "maintenance_window" {
  description = "Janela semanal de manutenção (UTC)."
  type        = string
  default     = "sun:07:00-sun:08:00"
}

variable "apply_immediately" {
  description = "Aplica mudanças fora da janela de manutenção."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
