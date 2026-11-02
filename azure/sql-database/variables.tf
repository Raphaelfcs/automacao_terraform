variable "server_name" {
  description = "Nome do servidor lógico (global)."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group."
  type        = string
}

variable "location" {
  description = "Região."
  type        = string
}

variable "entra_admin_login" {
  description = "Nome do grupo/usuário administrador no Entra ID."
  type        = string
}

variable "entra_admin_object_id" {
  description = "Object ID do administrador Entra ID."
  type        = string
}

variable "public_network_access" {
  description = "Acesso público (false = Private Endpoint)."
  type        = bool
  default     = false
}

variable "tde_key_vault_id" {
  description = "Key Vault da chave TDE (null = chave gerenciada pelo serviço)."
  type        = string
  default     = null
}

variable "tde_key_vault_key_id" {
  description = "ID da chave TDE."
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Workspace da auditoria (null = sem auditoria)."
  type        = string
  default     = null
}

variable "databases" {
  description = "Bancos por nome."
  type = map(object({
    sku_name              = optional(string, "GP_S_Gen5_2")
    max_size_gb           = optional(number, 32)
    zone_redundant        = optional(bool, false)
    backup_retention_days = optional(number, 7)
    ltr_weekly            = optional(string, "P4W")
    ltr_monthly           = optional(string, "P12M")
  }))
  default = {}
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
