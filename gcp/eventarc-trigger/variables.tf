variable "project_id" {
  description = "Projeto do GCP."
  type        = string
}

variable "region" {
  description = "Região dos gatilhos (a mesma do bucket/banco de origem e do serviço)."
  type        = string
  default     = "southamerica-east1"
}

variable "cloud_run_service" {
  description = "Nome do serviço Cloud Run de destino."
  type        = string
}

variable "service_account_id" {
  description = "ID da conta de serviço dos gatilhos."
  type        = string
}

variable "triggers" {
  description = <<-EOT
    Gatilhos: nome -> { filters (atributo = valor, inclui "type"), path_patterns (atributo =
    padrão, ex.: document = "itens/{id}"), path no serviço, content_type }.
  EOT
  type = map(object({
    filters       = map(string)
    path_patterns = optional(map(string), {})
    path          = string
    content_type  = optional(string, "application/json")
  }))

  validation {
    condition     = alltrue([for t in values(var.triggers) : contains(keys(t.filters), "type") && startswith(t.path, "/")])
    error_message = "Cada gatilho precisa do filtro type e de path começando com /."
  }
}

variable "grant_storage_publisher" {
  description = "Dá ao agente do Cloud Storage o papel de publicar no Pub/Sub (necessário para gatilhos de bucket)."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels aplicados."
  type        = map(string)
  default     = {}
}
