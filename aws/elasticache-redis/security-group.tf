resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-cache"
  description = "Acesso ao cache de ${var.name_prefix}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-cache" })
}

resource "aws_vpc_security_group_ingress_rule" "cache" {
  for_each = var.ingress_security_groups

  security_group_id            = aws_security_group.this.id
  description                  = "Cache a partir de ${each.key}"
  referenced_security_group_id = each.value
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
}
