# Conta Network (hub-and-spoke): Transit Gateway compartilhado via RAM com as contas de
# workload, tabelas de rota segmentadas (prod, nonprod, shared), Direct Connect (transit
# VIFs), VPN de backup e DNS híbrido (Route 53 Resolver). As VPCs spoke se anexam ao TGW
# e são associadas a um domínio de roteamento.
data "aws_region" "current" {}

# ----------------------------------------------------------------------------- Transit Gateway
resource "aws_ec2_transit_gateway" "this" {
  description                     = "${local.name} - hub da organização"
  amazon_side_asn                 = var.tgw_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags                            = merge(local.tags, { Name = "${local.name}-tgw" })
}

resource "aws_ec2_transit_gateway_route_table" "domain" {
  for_each           = toset(concat(var.route_domains, ["hub"]))
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags               = merge(local.tags, { Name = "${local.name}-rt-${each.key}" })
}

resource "aws_ram_resource_share" "tgw" {
  name                      = "${local.name}-tgw"
  allow_external_principals = false
  tags                      = local.tags
}

resource "aws_ram_resource_association" "tgw" {
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}

resource "aws_ram_principal_association" "tgw" {
  for_each           = toset(var.share_with_principals)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.tgw.arn
}

# ----------------------------------------------------------------------------- VPC do hub
resource "aws_vpc" "hub" {
  cidr_block           = var.hub_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "${local.name}-hub" })
}

resource "aws_subnet" "tgw" {
  for_each          = local.tgw_subnets
  vpc_id            = aws_vpc.hub.id
  availability_zone = each.key
  cidr_block        = each.value
  tags              = merge(local.tags, { Name = "${local.name}-tgw-${each.key}" })
}

resource "aws_subnet" "resolver" {
  for_each          = local.resolver_subnets
  vpc_id            = aws_vpc.hub.id
  availability_zone = each.key
  cidr_block        = each.value
  tags              = merge(local.tags, { Name = "${local.name}-resolver-${each.key}" })
}

resource "aws_route_table" "hub" {
  vpc_id = aws_vpc.hub.id
  tags   = merge(local.tags, { Name = "${local.name}-hub-privada" })
}

resource "aws_route" "hub_to_tgw" {
  for_each               = toset(concat(var.onprem_cidrs, ["10.0.0.0/8"]))
  route_table_id         = aws_route_table.hub.id
  destination_cidr_block = each.value
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.hub]
}

resource "aws_route_table_association" "resolver" {
  for_each       = aws_subnet.resolver
  subnet_id      = each.value.id
  route_table_id = aws_route_table.hub.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  transit_gateway_id                              = aws_ec2_transit_gateway.this.id
  vpc_id                                          = aws_vpc.hub.id
  subnet_ids                                      = [for s in aws_subnet.tgw : s.id]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags                                            = merge(local.tags, { Name = "${local.name}-hub" })
}

resource "aws_ec2_transit_gateway_route_table_association" "hub" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.domain["hub"].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "hub" {
  for_each                       = toset(var.route_domains)
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.domain[each.key].id
}

resource "aws_flow_log" "hub" {
  count                = var.flow_logs_bucket_arn == "" ? 0 : 1
  vpc_id               = aws_vpc.hub.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = var.flow_logs_bucket_arn
  tags                 = local.tags
}

# ----------------------------------------------------------------------------- Direct Connect 2 × 1 Gbps
resource "aws_dx_gateway" "this" {
  count           = var.enable_direct_connect ? 1 : 0
  name            = "${local.name}-dxgw"
  amazon_side_asn = var.dx_gateway_asn
}

resource "aws_dx_gateway_association" "tgw" {
  count                 = var.enable_direct_connect ? 1 : 0
  dx_gateway_id         = aws_dx_gateway.this[0].id
  associated_gateway_id = aws_ec2_transit_gateway.this.id
  allowed_prefixes      = ["10.0.0.0/8"] # anuncia ao on-premises só as redes AWS
}

resource "aws_dx_transit_virtual_interface" "this" {
  for_each       = var.enable_direct_connect ? local.vifs : {}
  name           = each.key
  connection_id  = each.value.connection_id
  dx_gateway_id  = aws_dx_gateway.this[0].id
  vlan           = each.value.vlan
  bgp_asn        = each.value.bgp_asn
  address_family = each.value.address_family
  mtu            = 8500
  tags           = local.tags
}

# ----------------------------------------------------------------------------- VPN de backup
resource "aws_customer_gateway" "this" {
  for_each   = local.cgws
  bgp_asn    = each.value.bgp_asn
  ip_address = each.value.ip_address
  type       = "ipsec.1"
  tags       = merge(local.tags, { Name = "${local.name}-cgw-${each.key}" })
}

resource "aws_vpn_connection" "this" {
  for_each            = local.cgws
  customer_gateway_id = aws_customer_gateway.this[each.key].id
  transit_gateway_id  = aws_ec2_transit_gateway.this.id
  type                = "ipsec.1"
  static_routes_only  = false
  tags                = merge(local.tags, { Name = "${local.name}-vpn-${each.key}" })
}

# o on-premises (DX e VPN) entra pela tabela hub e é propagado para todos os domínios
resource "aws_ec2_transit_gateway_route_table_association" "vpn" {
  for_each                       = aws_vpn_connection.this
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.domain["hub"].id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpn" {
  for_each = {
    for pair in setproduct(keys(local.cgws), var.route_domains) : "${pair[0]}|${pair[1]}" => { vpn = pair[0], domain = pair[1] }
  }
  transit_gateway_attachment_id  = aws_vpn_connection.this[each.value.vpn].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.domain[each.value.domain].id
}

# ----------------------------------------------------------------------------- DNS híbrido com o AD
resource "aws_security_group" "resolver" {
  name        = "${local.name}-resolver"
  description = "Route 53 Resolver: DNS entre AWS e o AD local"
  vpc_id      = aws_vpc.hub.id
  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    content {
      description = "DNS ${ingress.value}"
      from_port   = 53
      to_port     = 53
      protocol    = ingress.value
      cidr_blocks = concat(var.onprem_cidrs, ["10.0.0.0/8"])
    }
  }
  dynamic "egress" {
    for_each = ["tcp", "udp"]
    content {
      description = "DNS ${egress.value}"
      from_port   = 53
      to_port     = 53
      protocol    = egress.value
      cidr_blocks = concat(var.onprem_cidrs, ["10.0.0.0/8"])
    }
  }
  tags = local.tags
}

resource "aws_route53_resolver_endpoint" "inbound" {
  name               = "${local.name}-entrada"
  direction          = "INBOUND"
  security_group_ids = [aws_security_group.resolver.id]
  dynamic "ip_address" {
    for_each = aws_subnet.resolver
    content {
      subnet_id = ip_address.value.id
    }
  }
  tags = local.tags
}

resource "aws_route53_resolver_endpoint" "outbound" {
  name               = "${local.name}-saida"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.resolver.id]
  dynamic "ip_address" {
    for_each = aws_subnet.resolver
    content {
      subnet_id = ip_address.value.id
    }
  }
  tags = local.tags
}

resource "aws_route53_resolver_rule" "onprem" {
  count                = length(var.onprem_dns_servers) > 0 ? 1 : 0
  name                 = "${local.name}-ad-local"
  domain_name          = var.onprem_dns_domain
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id
  dynamic "target_ip" {
    for_each = var.onprem_dns_servers
    content {
      ip = target_ip.value
    }
  }
  tags = local.tags
}

resource "aws_ram_resource_association" "resolver_rule" {
  count              = length(aws_route53_resolver_rule.onprem)
  resource_arn       = aws_route53_resolver_rule.onprem[0].arn
  resource_share_arn = aws_ram_resource_share.tgw.arn
}
