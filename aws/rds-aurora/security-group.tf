resource "aws_security_group" "this" {
  name        = "${var.name}-aurora"
  description = "Acesso ao Aurora ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-aurora" })
}

resource "aws_vpc_security_group_ingress_rule" "sg" {
  for_each = var.ingress_security_groups

  security_group_id            = aws_security_group.this.id
  description                  = "Banco a partir de ${each.key}"
  referenced_security_group_id = each.value
  from_port                    = local.port
  to_port                      = local.port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "cidr" {
  for_each = toset(var.ingress_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "Banco a partir de ${each.value}"
  cidr_ipv4         = each.value
  from_port         = local.port
  to_port           = local.port
  ip_protocol       = "tcp"
}
