variable "zone_name" {
  description = "Nome da zona privada (ex.: interno.empresa.local). Evite colidir com zonas da outra conta."
  type        = string
}

variable "comment" {
  description = "Comentário da zona."
  type        = string
  default     = "Zona privada gerenciada por Terraform"
}

variable "vpcs" {
  description = "VPCs desta conta associadas na criação: rótulo -> { vpc_id, region }."
  type = map(object({
    vpc_id = string
    region = string
  }))
}

variable "additional_vpcs" {
  description = "VPCs desta conta associadas depois da criação."
  type = map(object({
    vpc_id = string
    region = string
  }))
  default = {}
}

variable "cross_account_vpcs" {
  description = "VPCs de OUTRAS contas autorizadas a associar a zona."
  type = map(object({
    vpc_id = string
    region = string
  }))
  default = {}
}

variable "cname_records" {
  description = "Nome curto -> DNS gerenciado pela AWS (ex.: { db = \"x.rds.amazonaws.com\" })."
  type        = map(string)
  default     = {}
}

variable "a_records" {
  description = "Nome curto -> lista de IPs privados fixos."
  type        = map(list(string))
  default     = {}
}

variable "ttl" {
  description = "TTL dos registros em segundos (baixo facilita trocas)."
  type        = number
  default     = 60
}

variable "tags" {
  description = "Tags da zona."
  type        = map(string)
  default     = {}
}
