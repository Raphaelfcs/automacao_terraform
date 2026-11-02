variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "network_name" {
  type    = string
  default = "vpc-lab"
}

variable "subnet" {
  description = "Sub-rede do GKE com as faixas secundárias de pods e serviços."
  type = object({
    name          = string
    cidr          = string
    pods_cidr     = string
    services_cidr = string
  })
}

variable "psa_range" {
  description = "Faixa reservada para serviços gerenciados com IP privado (Cloud SQL)."
  type = object({
    address       = string
    prefix_length = number
  })
}
