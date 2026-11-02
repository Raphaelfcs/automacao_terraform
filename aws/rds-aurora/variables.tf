variable "name" {
  description = "Identificador do cluster."
  type        = string
}

variable "engine" {
  description = "aurora-mysql ou aurora-postgresql."
  type        = string
  default     = "aurora-postgresql"

  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql"], var.engine)
    error_message = "engine deve ser aurora-mysql ou aurora-postgresql."
  }
}

variable "engine_version" {
  description = "Versão do motor (ex.: 16.4 para PostgreSQL, 8.0.mysql_aurora.3.08.0 para MySQL)."
  type        = string
}

variable "parameter_group_family" {
  description = "Família do parameter group (ex.: aurora-postgresql16, aurora-mysql8.0)."
  type        = string
}

variable "cluster_parameters" {
  description = "Parâmetros adicionais do cluster."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC do cluster."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas (mínimo duas AZs)."
  type        = list(string)
}

variable "ingress_security_groups" {
  description = "SGs autorizados na porta do banco: nome estático -> id."
  type        = map(string)
  default     = {}
}

variable "ingress_cidrs" {
  description = "CIDRs autorizados (prefira SGs; use para redes on-premises via VPN/DX)."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "Chave KMS do storage, do secret master e do Performance Insights."
  type        = string
}

variable "database_name" {
  description = "Banco inicial."
  type        = string
  default     = null
}

variable "master_username" {
  description = "Usuário master (senha gerenciada pela AWS no Secrets Manager)."
  type        = string
  default     = "dbadmin"
}

variable "instances" {
  description = "Instâncias do cluster por nome (a de menor promotion_tier vira writer preferida)."
  type = map(object({
    instance_class = optional(string, "db.r7g.large")
    promotion_tier = optional(number, 1)
  }))
  default = {
    "1" = { promotion_tier = 0 }
    "2" = {}
  }
}

variable "serverless_v2" {
  description = "Capacidade Serverless v2 em ACUs. null = instâncias provisionadas."
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

variable "replica_autoscaling" {
  description = "Autoscaling de réplicas de leitura por CPU. null = desligado."
  type = object({
    min_capacity = number
    max_capacity = number
    target_cpu   = optional(number, 70)
  })
  default = null
}

variable "backup_retention_period" {
  description = "Dias de backup (1 a 35)."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Janela diária de backup (UTC)."
  type        = string
  default     = "05:00-06:00"
}

variable "maintenance_window" {
  description = "Janela semanal de manutenção (UTC)."
  type        = string
  default     = "sun:06:30-sun:07:30"
}

variable "backtrack_window_hours" {
  description = "Backtrack (só Aurora MySQL), em horas. 0 desliga."
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "Impede exclusão acidental."
  type        = bool
  default     = true
}

variable "final_snapshot" {
  description = "Cria snapshot final ao destruir."
  type        = bool
  default     = true
}

variable "iam_database_authentication" {
  description = "Habilita autenticação por IAM."
  type        = bool
  default     = false
}

variable "performance_insights_enabled" {
  description = "Liga o Performance Insights."
  type        = bool
  default     = true
}

variable "enhanced_monitoring_interval" {
  description = "Intervalo do Enhanced Monitoring (0 desliga)."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
