variable "parent_zone_id" {
  description = "ID da zona pai (na conta onde este módulo é aplicado)."
  type        = string
}

variable "subdomain" {
  description = "FQDN do subdomínio delegado (ex.: dev.example.com)."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9]([a-z0-9-]*[a-z0-9])?\\.)+[a-z]{2,}$", var.subdomain))
    error_message = "Use um FQDN em minúsculas, sem ponto final."
  }
}

variable "name_servers" {
  description = "Servidores de nome da zona filha."
  type        = list(string)

  validation {
    condition     = length(var.name_servers) >= 2
    error_message = "Informe ao menos dois servidores de nome."
  }
}

variable "ttl" {
  description = "TTL do registro NS (segundos). Comece baixo e aumente quando estabilizar."
  type        = number
  default     = 300
}
