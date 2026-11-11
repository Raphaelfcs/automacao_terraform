variable "zone_id" {
  description = "Zona hospedada do Route 53."
  type        = string
}

variable "records" {
  description = "Registros: chave lógica -> { name, type, values, ttl }."
  type = map(object({
    name   = string
    type   = string
    values = list(string)
    ttl    = optional(number, 300)
  }))

  validation {
    condition     = alltrue([for r in values(var.records) : contains(["A", "AAAA", "CNAME", "TXT", "MX", "CAA", "NS"], r.type)])
    error_message = "Tipo de registro não suportado."
  }
}
