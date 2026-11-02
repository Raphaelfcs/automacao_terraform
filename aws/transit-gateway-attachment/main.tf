# Anexa uma VPC a um Transit Gateway existente (próprio ou compartilhado via RAM) e cria,
# nas tabelas de rota privadas da VPC, as rotas para os CIDRs remotos via TGW.
#
# Cuidado operacional: se outra VPC anexada ao mesmo TGW anunciar o MESMO CIDR, o destino
# do tráfego fica não determinístico. Planeje o IPAM antes de ligar o attachment.

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  count = var.enabled ? 1 : 0

  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  appliance_mode_support = var.appliance_mode ? "enable" : "disable"
  dns_support            = "enable"

  transit_gateway_default_route_table_association = var.default_route_table_association
  transit_gateway_default_route_table_propagation = var.default_route_table_propagation

  tags = merge(var.tags, { Name = "${var.name_prefix}-tgw-attachment" })
}

resource "aws_route" "remote" {
  for_each = var.enabled ? local.routes : {}

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}
