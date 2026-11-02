variable "name_prefix" {
  description = "Prefixo aplicado ao nome de todos os recursos de rede."
  type        = string
}

variable "cidr_block" {
  description = "CIDR da VPC (ex.: 10.20.0.0/16). Planeje sem sobreposição com outras VPCs e on-premises."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block deve ser um CIDR IPv4 válido."
  }
}

variable "azs" {
  description = "Availability zones. Produção: 3 AZs; dev pode usar 2 para conter custo de NAT."
  type        = list(string)
}

variable "subnet_newbits" {
  description = "Bits adicionais para fatiar o CIDR (/16 + 4 = subnets /20)."
  type        = number
  default     = 4
}

variable "enable_nat_gateway" {
  description = "Cria NAT Gateway(s) para saída das subnets privadas."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Um único NAT para todas as AZs (dev). false = um NAT por AZ (produção, sem ponto único de falha)."
  type        = bool
  default     = false
}

variable "create_data_subnets" {
  description = "Cria a camada de dados isolada (sem rota para a internet)."
  type        = bool
  default     = true
}

variable "eks_cluster_name" {
  description = "Cluster EKS que consumirá as subnets (adiciona tags de descoberta de ELB). null = sem tags EKS."
  type        = string
  default     = null
}

variable "flow_logs_retention_days" {
  description = "Retenção dos flow logs em dias. 0 desliga."
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "Chave KMS do log group dos flow logs. null = cifra padrão do CloudWatch."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
