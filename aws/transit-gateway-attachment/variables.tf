variable "name_prefix" {
  description = "Prefixo do nome do attachment."
  type        = string
}

variable "enabled" {
  description = "Liga o attachment e as rotas (permite desligar sem remover o módulo)."
  type        = bool
  default     = true
}

variable "transit_gateway_id" {
  description = "ID do Transit Gateway (criado fora deste módulo)."
  type        = string
}

variable "vpc_id" {
  description = "VPC a anexar."
  type        = string
}

variable "subnet_ids" {
  description = "Uma subnet privada por AZ para as ENIs do attachment (de preferência /28 dedicadas)."
  type        = list(string)
}

variable "route_table_ids" {
  description = "Tabelas de rota da VPC que recebem as rotas para os CIDRs remotos."
  type        = list(string)
  default     = []
}

variable "remote_cidrs" {
  description = "CIDRs alcançados via TGW (outras VPCs, on-premises)."
  type        = list(string)
  default     = []
}

variable "appliance_mode" {
  description = "Liga appliance mode (simetria de fluxo para firewalls de inspeção)."
  type        = bool
  default     = false
}

variable "default_route_table_association" {
  description = "Associa à route table padrão do TGW (false quando há tabelas segmentadas)."
  type        = bool
  default     = true
}

variable "default_route_table_propagation" {
  description = "Propaga para a route table padrão do TGW."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
