# Security group declarativo: regras de entrada/saída por mapa, usando os recursos
# aws_vpc_security_group_*_rule (uma regra por recurso, sem diff perpétuo de regras
# inline) e referência a outros SGs em vez de CIDR sempre que possível.

resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.ingress_rules

  security_group_id            = aws_security_group.this.id
  description                  = each.key
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.protocol == "-1" ? null : each.value.from_port
  to_port                      = each.value.protocol == "-1" ? null : coalesce(each.value.to_port, each.value.from_port)
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.source_security_group_id
  prefix_list_id               = each.value.prefix_list_id
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.egress_rules

  security_group_id            = aws_security_group.this.id
  description                  = each.key
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.protocol == "-1" ? null : each.value.from_port
  to_port                      = each.value.protocol == "-1" ? null : coalesce(each.value.to_port, each.value.from_port)
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.destination_security_group_id
  prefix_list_id               = each.value.prefix_list_id
}
