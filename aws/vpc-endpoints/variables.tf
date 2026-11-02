variable "name_prefix" {
  description = "Prefixo dos nomes."
  type        = string
}

variable "vpc_id" {
  description = "VPC dos endpoints."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets privadas dos Interface endpoints (uma por AZ)."
  type        = list(string)
  default     = []
}

variable "route_table_ids" {
  description = "Tabelas de rota dos Gateway endpoints (s3, dynamodb)."
  type        = list(string)
  default     = []
}

variable "interface_services" {
  description = "Serviços Interface (cada um custa por hora por AZ — habilite só o necessário)."
  type        = list(string)
  default     = ["ssm", "ssmmessages", "ec2messages"]
}

variable "gateway_services" {
  description = "Serviços Gateway (gratuitos): s3, dynamodb."
  type        = list(string)
  default     = ["s3"]
}

variable "allowed_cidrs" {
  description = "CIDRs adicionais autorizados (ex.: VPCs peered/TGW)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
