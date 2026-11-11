variable "name" {
  description = "Nome da Web ACL."
  type        = string
}

variable "scope" {
  description = "CLOUDFRONT (provider em us-east-1) ou REGIONAL (ALB, API Gateway REST, AppSync)."
  type        = string
  default     = "CLOUDFRONT"

  validation {
    condition     = contains(["CLOUDFRONT", "REGIONAL"], var.scope)
    error_message = "scope deve ser CLOUDFRONT ou REGIONAL."
  }
}

variable "managed_rule_groups" {
  description = "Grupos gerenciados da AWS, em ordem de avaliação. Cada um custa como uma regra."
  type        = list(string)
  default     = ["AWSManagedRulesCommonRuleSet", "AWSManagedRulesKnownBadInputsRuleSet", "AWSManagedRulesAmazonIpReputationList"]
}

variable "managed_rule_overrides" {
  description = "Regras de um grupo gerenciado que só contam em vez de bloquear (ex.: SizeRestrictions_BODY para uploads)."
  type        = map(list(string))
  default     = {}
}

variable "count_only" {
  description = "Modo observação: grupos gerenciados só contam. Use na primeira semana para medir falsos positivos."
  type        = bool
  default     = false
}

variable "rate_limit_per_5min" {
  description = "Requisições por IP em 5 minutos antes do bloqueio."
  type        = number
  default     = 1000

  validation {
    condition     = var.rate_limit_per_5min >= 10
    error_message = "O WAF exige limite mínimo de 10."
  }
}

variable "allowed_countries" {
  description = "Códigos ISO de países permitidos (ex.: [\"BR\"]). Vazio = sem restrição geográfica."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Retenção dos logs do WAF no CloudWatch. null = sem logs."
  type        = number
  default     = 90
}

variable "kms_key_arn" {
  description = "Chave KMS dos logs (na mesma região da Web ACL)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
