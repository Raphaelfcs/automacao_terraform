variable "account_name" {
  description = "Nome da conta (aparece no Organizations e no portal do Identity Center)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,49}$", var.account_name))
    error_message = "Use minúsculas, números e hífen (3 a 50 caracteres)."
  }
}

variable "account_email" {
  description = "E-mail do root da conta (único em toda a AWS; use alias +funcao)."
  type        = string

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.account_email))
    error_message = "E-mail inválido."
  }
}

variable "managed_organizational_unit" {
  description = "OU registrada de destino. OU aninhada usa o formato \"Nome (ou-xxxx-yyyyyyyy)\"."
  type        = string
}

variable "sso_user" {
  description = "Usuário do Identity Center dono da conta. email null = usa o e-mail da conta."
  type = object({
    first_name = string
    last_name  = string
    email      = optional(string)
  })
}

variable "provisioned_product_name" {
  description = "Nome do produto provisionado no Service Catalog. null = conta-<account_name>."
  type        = string
  default     = null
}

variable "product_name" {
  description = "Produto do Service Catalog criado pelo Control Tower."
  type        = string
  default     = "AWS Control Tower Account Factory"
}

variable "provisioning_artifact_name" {
  description = "Versão (provisioning artifact) do produto do Account Factory."
  type        = string
  default     = "AWS Control Tower Account Factory"
}

variable "tags" {
  description = "Tags adicionais (aplicadas ao produto provisionado)."
  type        = map(string)
  default     = {}
}
