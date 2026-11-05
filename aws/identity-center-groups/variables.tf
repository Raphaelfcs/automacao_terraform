variable "groups" {
  description = "Grupos por nome (DisplayName) com a descrição."
  type        = map(string)
}

variable "users" {
  description = "Usuários do diretório interno por user_name (geralmente o e-mail) e os grupos de cada um. Com IdP externo (SCIM), deixe vazio."
  type = map(object({
    given_name  = string
    family_name = string
    email       = optional(string)
    groups      = optional(list(string), [])
  }))
  default = {}

  validation {
    condition     = alltrue(flatten([for u in values(var.users) : [for g in u.groups : contains(keys(var.groups), g)]]))
    error_message = "Todo grupo citado em users precisa existir em groups."
  }
}
