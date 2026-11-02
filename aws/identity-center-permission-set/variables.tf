variable "permission_sets" {
  description = "Permission sets por nome."
  type = map(object({
    description               = optional(string, "")
    session_duration          = optional(string, "PT4H")
    managed_policy_arns       = optional(list(string), [])
    inline_policy             = optional(string)
    customer_managed_policies = optional(list(string), [])
    boundary_policy_name      = optional(string)
  }))
}

variable "account_assignments" {
  description = "Atribuições: grupo do Identity Store (DisplayName) recebe o permission set na conta."
  type = list(object({
    permission_set = string
    group          = string
    account_id     = string
  }))
  default = []
}

variable "tags" {
  description = "Tags dos permission sets."
  type        = map(string)
  default     = {}
}
