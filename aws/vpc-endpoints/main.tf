# VPC Endpoints (Interface e Gateway) para acesso privado a serviços AWS sem NAT/internet
# (ex.: ssm, ssmmessages, ec2messages, ecr.api, ecr.dkr, logs, sts, secretsmanager, s3).
# Os Interface endpoints compartilham um SG que libera 443 apenas a partir da VPC.

data "aws_region" "current" {}

data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_security_group" "endpoints" {
  count = length(var.interface_services) > 0 ? 1 : 0

  name        = "${var.name_prefix}-vpce"
  description = "HTTPS para VPC endpoints a partir da VPC"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpce" })
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = length(var.interface_services) > 0 ? toset(concat([data.aws_vpc.this.cidr_block], var.allowed_cidrs)) : toset([])

  security_group_id = aws_security_group.endpoints[0].id
  description       = "HTTPS de ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(var.interface_services)

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [aws_security_group.endpoints[0].id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpce-${each.value}" })
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = toset(var.gateway_services)

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.${each.value}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpce-${each.value}" })
}
