variable "export_name" {
  description = "Nome da exportação FOCUS."
  type        = string
  default     = "focus-1-0"
}

variable "bucket_name" {
  description = "Bucket de destino (criado aqui ou existente)."
  type        = string
}

variable "create_bucket" {
  description = "Cria o bucket com a política para o Data Exports. false = use um bucket existente já com a política."
  type        = bool
  default     = true
}

variable "bucket_region" {
  description = "Região do bucket de destino."
  type        = string
  default     = "us-east-1"
}

variable "s3_prefix" {
  description = "Prefixo dos arquivos exportados."
  type        = string
  default     = "focus"
}

variable "retention_days" {
  description = "Expiração dos arquivos exportados (0 = sem expiração)."
  type        = number
  default     = 0
}

variable "focus_columns" {
  description = "Colunas FOCUS selecionadas. Padrão: conjunto essencial para showback/chargeback."
  type        = list(string)
  default = [
    "BilledCost", "BillingAccountId", "BillingPeriodStart", "BillingPeriodEnd", "ChargeCategory",
    "ChargeDescription", "ChargePeriodStart", "ChargePeriodEnd", "EffectiveCost", "ListCost",
    "PricingQuantity", "PricingUnit", "ProviderName", "RegionId", "ResourceId", "ResourceName",
    "ServiceCategory", "ServiceName", "SubAccountId", "SubAccountName", "Tags", "UsageQuantity", "UsageUnit",
  ]
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
