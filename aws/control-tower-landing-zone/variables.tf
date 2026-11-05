variable "governed_regions" {
  description = "Regiões governadas pelo Control Tower. A primeira deve ser a home region (de onde o módulo roda)."
  type        = list(string)

  validation {
    condition     = length(var.governed_regions) > 0
    error_message = "Informe ao menos a home region."
  }
}

variable "landing_zone_version" {
  description = "Versão da landing zone. Este módulo monta o manifesto no formato 4.0."
  type        = string
  default     = "4.0"
}

variable "security_ou_name" {
  description = "Nome da OU das contas de serviço (Log Archive e Audit), logo abaixo da raiz."
  type        = string
  default     = "Security"
}

variable "existing_security_ou_id" {
  description = "ID de uma OU de segurança já existente. null = o módulo cria a OU."
  type        = string
  default     = null
}

variable "log_archive_account" {
  description = "Conta Log Archive. Sem id, o módulo cria a conta com nome e e-mail informados."
  type = object({
    name  = string
    email = string
    id    = optional(string)
  })

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.log_archive_account.email))
    error_message = "E-mail inválido para a conta Log Archive."
  }
}

variable "audit_account" {
  description = "Conta Audit (Security Tooling). Sem id, o módulo cria a conta com nome e e-mail informados."
  type = object({
    name  = string
    email = string
    id    = optional(string)
  })

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.audit_account.email))
    error_message = "E-mail inválido para a conta Audit."
  }
}

variable "enable_identity_center" {
  description = "Integração com o IAM Identity Center (accessManagement): grupos e permission sets do Control Tower."
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Integração com o AWS Config (agregador na conta Audit). Desligar obriga a desligar Identity Center, security roles e Backup."
  type        = bool
  default     = true
}

variable "enable_security_roles" {
  description = "Cria as roles de auditoria cross-account na conta Audit."
  type        = bool
  default     = true
}

variable "enable_centralized_logging" {
  description = "CloudTrail organizacional e bucket de logs na conta Log Archive."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Retenção (dias) dos logs do CloudTrail e do Config."
  type        = number
  default     = 365

  validation {
    condition     = var.log_retention_days >= 1
    error_message = "A retenção mínima é 1 dia."
  }
}

variable "access_log_retention_days" {
  description = "Retenção (dias) dos access logs dos buckets de log."
  type        = number
  default     = 90

  validation {
    condition     = var.access_log_retention_days >= 1
    error_message = "A retenção mínima é 1 dia."
  }
}

variable "kms_key_arn" {
  description = "Chave KMS para os logs do CloudTrail e do Config. null = criptografia gerenciada pela AWS."
  type        = string
  default     = null
}

variable "backup" {
  description = "Integração com AWS Backup (contas admin e central + chave KMS). null = desligada (FinOps)."
  type = object({
    admin_account_id   = string
    central_account_id = string
    kms_key_arn        = string
  })
  default = null
}

variable "tags" {
  description = "Tags adicionais."
  type        = map(string)
  default     = {}
}
