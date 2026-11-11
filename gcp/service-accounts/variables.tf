variable "project_id" {
  description = "Projeto do GCP."
  type        = string
}

variable "accounts" {
  description = "Contas: account_id -> { display_name, project_roles, self_sign }."
  type = map(object({
    display_name  = string
    project_roles = optional(list(string), [])
    self_sign     = optional(bool, false)
  }))

  validation {
    condition     = alltrue([for k in keys(var.accounts) : can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", k))])
    error_message = "account_id com 6 a 30 caracteres: minúsculas, números e hífen."
  }

  validation {
    condition     = !anytrue(flatten([for a in values(var.accounts) : [for p in a.project_roles : contains(["roles/owner", "roles/editor"], p)]]))
    error_message = "Papéis básicos (owner/editor) não são aceitos: use papéis específicos."
  }
}
