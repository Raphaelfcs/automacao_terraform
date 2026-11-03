variable "name_prefix" {
  description = "Prefixo dos recursos de segurança."
  type        = string
  default     = "security-baseline"
}

variable "tags" {
  description = "Tags adicionais."
  type        = map(string)
  default     = {}
}

variable "enable_detection" {
  description = "Liga detecção e alertas (GuardDuty, Security Hub, Inspector, Macie, Access Analyzer). Desligue na instância que cria só o bucket da Log Archive."
  type        = bool
  default     = true
}

variable "alert_emails" {
  description = "E-mails do time que recebem alertas críticos (GuardDuty, Security Hub)."
  type        = list(string)
  default     = []
}

variable "guardduty_min_severity" {
  description = "Severidade mínima de achados do GuardDuty que geram alerta (7 = alta)."
  type        = number
  default     = 7
}

variable "enable_inspector" {
  description = "Ativa o Inspector para EC2, ECR e Lambda nas contas da organização."
  type        = bool
  default     = true
}

variable "enable_macie" {
  description = "Ativa o Macie (descoberta de dados pessoais em S3, LGPD)."
  type        = bool
  default     = true
}

variable "securityhub_standards" {
  description = "Padrões do Security Hub habilitados."
  type        = list(string)
  default = [
    "standards/aws-foundational-security-best-practices/v/1.0.0",
    "standards/cis-aws-foundations-benchmark/v/1.4.0",
  ]
}

# ----------------------------------------------------------------- Log Archive (opcional)
variable "create_log_archive_bucket" {
  description = "Cria o bucket imutável da conta Log Archive (rode com o provider dessa conta)."
  type        = bool
  default     = false
}

variable "organization_id" {
  description = "ID da organização (o-xxxx), para a política do bucket de logs."
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Retenção mínima (Object Lock COMPLIANCE) dos logs de auditoria."
  type        = number
  default     = 365
}
