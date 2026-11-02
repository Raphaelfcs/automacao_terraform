variable "name" {
  description = "Nome da storage account (3-24, minúsculas e números, global)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Use 3 a 24 caracteres minúsculos/números."
  }
}

variable "resource_group_name" {
  description = "Resource group."
  type        = string
}

variable "location" {
  description = "Região (ex.: brazilsouth)."
  type        = string
}

variable "account_tier" {
  description = "Standard ou Premium."
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "LRS, ZRS, GRS, RAGRS, GZRS ou RAGZRS."
  type        = string
  default     = "ZRS"
}

variable "hierarchical_namespace" {
  description = "Data Lake Gen2 (HNS)."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Permite chaves de conta/SAS por chave. Prefira false (Entra ID)."
  type        = bool
  default     = false
}

variable "public_network_access" {
  description = "Acesso por rede pública (false = só Private Endpoint/subnets permitidas)."
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "IPs/CIDRs públicos permitidos."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "Subnets com service endpoint permitidas."
  type        = list(string)
  default     = []
}

variable "cmk_key_vault_id" {
  description = "Key Vault da CMK (para a role de criptografia). null = chave da Microsoft."
  type        = string
  default     = null
}

variable "cmk_key_vault_key_id" {
  description = "ID versionless da chave no Key Vault."
  type        = string
  default     = null
}

variable "versioning" {
  description = "Versionamento de blobs."
  type        = bool
  default     = true
}

variable "soft_delete_days" {
  description = "Retenção do soft delete de blobs e containers."
  type        = number
  default     = 14
}

variable "containers" {
  description = "Containers privados criados."
  type        = list(string)
  default     = []
}

variable "data_contributors" {
  description = "principal_id -> role de dados (ex.: Storage Blob Data Contributor)."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
