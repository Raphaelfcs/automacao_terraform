resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-msk"
  description = "Acesso ao cluster MSK ${var.name_prefix}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-msk" })
}

resource "aws_vpc_security_group_ingress_rule" "tls" {
  for_each = var.ingress_security_groups

  security_group_id            = aws_security_group.this.id
  description                  = "Kafka TLS a partir de ${each.key}"
  referenced_security_group_id = each.value
  from_port                    = 9094
  to_port                      = 9094
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "iam_sasl" {
  for_each = var.ingress_security_groups

  security_group_id            = aws_security_group.this.id
  description                  = "Kafka SASL/IAM a partir de ${each.key}"
  referenced_security_group_id = each.value
  from_port                    = 9098
  to_port                      = 9098
  ip_protocol                  = "tcp"
}
