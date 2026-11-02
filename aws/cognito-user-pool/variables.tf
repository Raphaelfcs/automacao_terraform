variable "name_prefix" {
  description = "Prefixo aplicado aos recursos de identidade."
  type        = string
}

variable "domain_prefix" {
  description = "Prefixo do domínio do Cognito (<prefixo>.auth.<regiao>.amazoncognito.com). Único na região."
  type        = string
}

variable "callback_urls" {
  description = "URLs de callback do authorization code. Explícitas — nunca curinga."
  type        = list(string)

  validation {
    condition     = length(var.callback_urls) > 0 && !anytrue([for u in var.callback_urls : strcontains(u, "*")])
    error_message = "callback_urls deve listar URLs explícitas; curinga não é aceito."
  }
}

variable "logout_urls" {
  description = "URLs de logout autorizadas."
  type        = list(string)
  default     = []
}

variable "mfa_configuration" {
  description = "OFF, ON ou OPTIONAL. Perfis sensíveis exigem ON."
  type        = string
  default     = "ON"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "mfa_configuration deve ser OFF, ON ou OPTIONAL."
  }
}

variable "admin_create_user_only" {
  description = "Só administradores criam usuários (sem auto-cadastro)."
  type        = bool
  default     = true
}

variable "advanced_security_mode" {
  description = "OFF, AUDIT ou ENFORCED (proteção contra credenciais vazadas/risco de login)."
  type        = string
  default     = "AUDIT"
}

variable "deletion_protection" {
  description = "Impede exclusão acidental do pool."
  type        = bool
  default     = true
}

variable "custom_attributes" {
  description = "Atributos customizados string: nome -> tamanho máximo (ex.: { tenant_id = 64 })."
  type        = map(number)
  default     = {}
}

variable "roles" {
  description = "Papéis RBAC materializados como grupos: código (vai no claim cognito:groups) -> descrição."
  type        = map(string)
  default     = {}
}

variable "resource_server_identifier" {
  description = "Identificador do resource server interno — prefixo dos escopos no token."
  type        = string
  default     = "api-interna"
}

variable "machine_scopes" {
  description = "Escopos de máquina: nome -> descrição."
  type        = map(string)
  default     = {}
}

variable "service_clients" {
  description = "Identidades de máquina: serviço -> lista de escopos de machine_scopes."
  type        = map(list(string))
  default     = {}
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
