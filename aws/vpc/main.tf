# VPC em três camadas por AZ: pública (ALB/NAT), privada (workloads, saída via NAT) e
# dados (bancos/caches, sem rota para a internet). Flow logs e endpoint S3 gateway inclusos.

data "aws_region" "current" {}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

# Fecha o SG default (CIS 5.4): nenhuma regra de entrada ou saída.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-default-fechado" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

resource "aws_subnet" "public" {
  for_each = { for i, az in var.azs : az => local.public_subnets[i] }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge(var.tags, local.eks_tags_public, { Name = "${var.name_prefix}-public-${each.key}", Tier = "public" })
}

resource "aws_subnet" "private" {
  for_each = { for i, az in var.azs : az => local.private_subnets[i] }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(var.tags, local.eks_tags_private, { Name = "${var.name_prefix}-private-${each.key}", Tier = "private" })
}

resource "aws_subnet" "data" {
  for_each = var.create_data_subnets ? { for i, az in var.azs : az => local.data_subnets[i] } : {}

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(var.tags, { Name = "${var.name_prefix}-data-${each.key}", Tier = "data" })
}

resource "aws_eip" "nat" {
  count = local.nat_count

  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name_prefix}-nat-${count.index}" })
}

resource "aws_nat_gateway" "this" {
  count = local.nat_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.azs[count.index]].id

  tags = merge(var.tags, { Name = "${var.name_prefix}-nat-${count.index}" })

  depends_on = [aws_internet_gateway.this]
}
