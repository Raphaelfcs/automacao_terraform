variable "name_prefix" {
  description = "Prefixo aplicado aos recursos do banco."
  type        = string
}

variable "engine" {
  description = "Motor do banco: mysql ou postgres."
  type        = string
  default     = "mysql"

  validation {
    condition     = contains(["mysql", "postgres"], var.engine)
    error_message = "engine deve ser mysql ou postgres."
  }
}

variable "engine_version" {
  description = "Versão do motor (ex.: 8.4.3 para MySQL, 16.4 para PostgreSQL)."
  type        = string
}

variable "instance_class" {
  description = "Classe da instância (ex.: db.t4g.micro em dev, db.r7g.large em produção)."
  type        = string
}

variable "vpc_id" {
  description = "VPC onde a instância vive."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas do subnet group (mínimo duas AZs)."
  type        = list(string)
}

variable "ingress_security_groups" {
  description = "Security groups autorizados na porta do banco: nome estático (chave) -> id (valor)."
  # Mapa com CHAVE ESTÁTICA, e não list(string): ids de SG criados no mesmo apply são
  # desconhecidos no plan, e for_each sobre lista desconhecida falha ("Invalid for_each argument").
  type    = map(string)
  default = {}
}

variable "kms_key_arn" {
  description = "Chave KMS para criptografia em repouso, do secret master e do Performance Insights."
  type        = string
}

variable "allocated_storage" {
  description = "Armazenamento inicial em GB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Limite do autoscaling de storage em GB. null = 2x o inicial."
  type        = number
  default     = null
}

variable "database_name" {
  description = "Nome do schema/banco inicial."
  type        = string
}

variable "master_username" {
  description = "Usuário administrativo. A senha é gerada pela AWS e guardada no Secrets Manager."
  type        = string
  default     = "dbadmin"
}

variable "multi_az" {
  description = "Standby síncrono em outra AZ. Obrigatório em produção (RPO/RTO); dispensável em sandbox."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "AZ da instância single-AZ. null = AWS escolhe."
  type        = string
  default     = null
}

variable "backup_retention_period" {
  description = "Dias de retenção do backup automático (0 a 35)."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Janela diária de backup em UTC (hh24:mi-hh24:mi)."
  type        = string
  default     = "05:00-06:00"
}

variable "maintenance_window" {
  description = "Janela semanal de manutenção em UTC."
  type        = string
  default     = "sun:06:30-sun:07:30"
}

variable "deletion_protection" {
  description = "Impede exclusão acidental. Use true em produção."
  type        = bool
  default     = true
}

variable "final_snapshot" {
  description = "Cria snapshot final ao destruir."
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Liga o Performance Insights (7 dias gratuitos)."
  type        = bool
  default     = true
}

variable "enhanced_monitoring_interval" {
  description = "Intervalo do Enhanced Monitoring em segundos (0 desliga; 1, 5, 10, 15, 30, 60)."
  type        = number
  default     = 0
}

variable "iam_database_authentication" {
  description = "Permite autenticação por IAM (tokens) além de usuário/senha."
  type        = bool
  default     = false
}

variable "extra_parameters" {
  description = "Parâmetros adicionais do parameter group (nome -> valor)."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
