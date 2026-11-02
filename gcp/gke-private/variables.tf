variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_name" {
  type    = string
  default = "gke-lab"
}

variable "network_self_link" {
  type = string
}

variable "subnet_self_link" {
  type = string
}

variable "pods_range_name" {
  type = string
}

variable "services_range_name" {
  type = string
}

variable "release_channel" {
  description = "RAPID, REGULAR ou STABLE."
  type        = string
  default     = "REGULAR"
}

variable "authorized_networks" {
  description = "Redes que podem chamar o plano de controle. Lista vazia = sem restrição (só para laboratório)."
  type        = list(object({ cidr = string, name = string }))
  default     = []
}

variable "maintenance_window" {
  description = "Janela recorrente de manutenção (UTC)."
  type = object({
    start      = string
    end        = string
    recurrence = string
  })
}

variable "artifact_repo" {
  type    = string
  default = "lab"
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "labels" {
  type    = map(string)
  default = {}
}
