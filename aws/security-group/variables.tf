variable "name" {
  description = "Nome do security group."
  type        = string
}

variable "description" {
  description = "Descrição (imutável após a criação na AWS)."
  type        = string
}

variable "vpc_id" {
  description = "VPC do SG."
  type        = string
}

variable "ingress_rules" {
  description = "Regras de entrada por descrição. Informe exatamente uma origem: cidr_ipv4, source_security_group_id ou prefix_list_id."
  type = map(object({
    protocol                 = optional(string, "tcp")
    from_port                = optional(number)
    to_port                  = optional(number)
    cidr_ipv4                = optional(string)
    source_security_group_id = optional(string)
    prefix_list_id           = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([for r in values(var.ingress_rules) :
    length(compact([r.cidr_ipv4, r.source_security_group_id, r.prefix_list_id])) == 1])
    error_message = "Cada regra de entrada precisa de exatamente uma origem."
  }

  validation {
    condition     = !anytrue([for r in values(var.ingress_rules) : r.cidr_ipv4 == "0.0.0.0/0" && !contains([80, 443], coalesce(r.from_port, -1))])
    error_message = "0.0.0.0/0 só é aceito nas portas 80/443."
  }
}

variable "egress_rules" {
  description = "Regras de saída por descrição. Padrão: toda saída."
  type = map(object({
    protocol                      = optional(string, "tcp")
    from_port                     = optional(number)
    to_port                       = optional(number)
    cidr_ipv4                     = optional(string)
    destination_security_group_id = optional(string)
    prefix_list_id                = optional(string)
  }))
  default = {
    "toda-saida" = { protocol = "-1", cidr_ipv4 = "0.0.0.0/0" }
  }
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
