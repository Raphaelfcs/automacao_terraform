resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-rt-public" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Uma tabela privada por AZ (ou uma só, com NAT único) — rotas adicionais (TGW, VPN)
# são anexadas por fora via output private_route_table_ids.
resource "aws_route_table" "private" {
  count = max(local.nat_count, 1)

  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-rt-private-${count.index}" })
}

resource "aws_route" "private_nat" {
  count = local.nat_count

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  for_each = { for i, az in var.azs : az => i }

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[local.nat_count > 1 ? each.value : 0].id
}

# Camada de dados: só rota local (e o endpoint S3). Nada sai para a internet.
resource "aws_route_table" "data" {
  count = var.create_data_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-rt-data" })
}

resource "aws_route_table_association" "data" {
  for_each = aws_subnet.data

  subnet_id      = each.value.id
  route_table_id = aws_route_table.data[0].id
}

# Endpoint S3 gateway: tráfego de imagens/artefatos/backup não paga NAT (pilar Custo).
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(aws_route_table.private[*].id, aws_route_table.data[*].id)

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpce-s3" })
}
