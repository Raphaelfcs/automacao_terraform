resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-${var.engine}"
  description = "Acesso ao RDS ${var.engine} de ${var.name_prefix}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-${var.engine}" })
}

# Somente security groups de origem — nenhum CIDR aberto.
resource "aws_vpc_security_group_ingress_rule" "db" {
  for_each = var.ingress_security_groups

  security_group_id            = aws_security_group.this.id
  description                  = "Banco a partir de ${each.key}"
  referenced_security_group_id = each.value
  from_port                    = local.port
  to_port                      = local.port
  ip_protocol                  = "tcp"
}
