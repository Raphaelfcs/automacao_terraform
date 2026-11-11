variable "zone_id" {
  description = "Zona hospedada do Route 53."
  type        = string
}

variable "record_name" {
  description = "Nome publicado (ex.: app.example.com)."
  type        = string
}

variable "endpoints" {
  description = <<-EOT
    Endpoints por nome lógico (ex.: aws, gcp). Cada um tem alias (CloudFront/ALB) OU ips,
    o peso no DNS e o alvo do health check: health_fqdn (nome que responde direto naquele
    endpoint) e, para IP, health_ip.
  EOT
  type = map(object({
    weight      = optional(number, 50)
    alias       = optional(object({ name = string, zone_id = string }))
    ips         = optional(list(string), [])
    health_fqdn = string
    health_ip   = optional(string)
  }))

  validation {
    condition     = alltrue([for e in values(var.endpoints) : (e.alias != null) != (length(e.ips) > 0)])
    error_message = "Cada endpoint precisa de alias OU ips, não os dois."
  }

  validation {
    condition     = length(var.endpoints) >= 2
    error_message = "Roteamento com health check só faz sentido com pelo menos dois endpoints."
  }
}

variable "health_path" {
  description = "Caminho que responde 200 sem autenticação."
  type        = string
  default     = "/api/health"
}

variable "health_regions" {
  description = "Regiões de onde o Route 53 checa (mínimo 3)."
  type        = list(string)
  default     = ["sa-east-1", "us-east-1", "us-west-2"]
}

variable "alarm_topic_arn" {
  description = "Tópico SNS para alarme de endpoint fora (o alarme do Route 53 fica em us-east-1). null = sem alarme."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
