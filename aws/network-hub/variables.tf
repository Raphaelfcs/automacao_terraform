variable "name_prefix" {
  description = "Prefixo dos recursos de rede."
  type        = string
  default     = "network-hub"
}

variable "tags" {
  description = "Tags adicionais."
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------------- Transit Gateway
variable "tgw_asn" {
  description = "ASN do lado AWS do Transit Gateway."
  type        = number
  default     = 64512
}

variable "route_domains" {
  description = "Domínios de roteamento (tabelas do TGW). Prod não fala com NonProd; todos falam com Shared e com o on-premises."
  type        = list(string)
  default     = ["prod", "nonprod", "shared"]
}

variable "share_with_principals" {
  description = "ARNs da organização ou de OUs com quem o TGW e as regras de DNS são compartilhados (RAM)."
  type        = list(string)
}

# ----------------------------------------------------------------- VPC do hub
variable "hub_vpc_cidr" {
  description = "CIDR da VPC do hub (anexo do TGW, Resolver, inspeção)."
  type        = string
  default     = "10.10.0.0/22"
}

variable "availability_zones" {
  description = "AZs usadas (2 para alta disponibilidade)."
  type        = list(string)
  default     = ["sa-east-1a", "sa-east-1b"]
}

variable "onprem_cidrs" {
  description = "Redes do data center e dos CDs (rotas pelo Direct Connect/VPN)."
  type        = list(string)
  default     = ["172.16.0.0/12"]
}

variable "flow_logs_bucket_arn" {
  description = "Bucket da conta Log Archive para os VPC Flow Logs (vazio = sem flow logs)."
  type        = string
  default     = ""
}

# ----------------------------------------------------------------- Direct Connect (2 × 1 Gbps)
variable "enable_direct_connect" {
  description = "Cria o Direct Connect Gateway associado ao TGW."
  type        = bool
  default     = true
}

variable "dx_gateway_asn" {
  description = "ASN do Direct Connect Gateway."
  type        = number
  default     = 64513
}

variable "dx_transit_vifs" {
  description = "Uma transit VIF por conexão física (2 × 1 Gbps em locais distintos). Conexões são pedidas ao parceiro antes."
  type        = list(object({
    name           = string
    connection_id  = string
    vlan           = number
    bgp_asn        = number
    address_family = optional(string, "ipv4")
  }))
  default = []
}

# ----------------------------------------------------------------- VPN de backup
variable "vpn_customer_gateways" {
  description = "Roteadores do data center para a VPN de backup (BGP)."
  type        = list(object({
    name       = string
    ip_address = string
    bgp_asn    = number
  }))
  default = []
}

# ----------------------------------------------------------------- DNS híbrido (Route 53 Resolver)
variable "onprem_dns_domain" {
  description = "Domínio do AD local resolvido pelos servidores DNS on-premises."
  type        = string
  default     = "corp.internal"
}

variable "onprem_dns_servers" {
  description = "IPs dos DNS do AD local para a regra de encaminhamento."
  type        = list(string)
  default     = []
}
