locals {
  name = var.name_prefix
  tags = merge({ Gerenciado = "terraform", Camada = "rede-hub" }, var.tags)

  # sub-redes da VPC do hub: anexo do TGW (/28) e endpoints do Resolver (/26) por AZ
  tgw_subnets      = { for i, az in var.availability_zones : az => cidrsubnet(var.hub_vpc_cidr, 6, i) }
  resolver_subnets = { for i, az in var.availability_zones : az => cidrsubnet(var.hub_vpc_cidr, 2, i + 1) }

  vifs = { for v in var.dx_transit_vifs : v.name => v }
  cgws = { for c in var.vpn_customer_gateways : c.name => c }
}
