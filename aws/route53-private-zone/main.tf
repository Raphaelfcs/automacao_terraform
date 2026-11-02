# Zona Route 53 PRIVADA com nomes estáveis para recursos internos (ALB, RDS, cache,
# serviços por IP fixo), associada a VPCs desta conta e autorizada para VPCs de outras
# contas (parceiros, contas de workload) via autorização cross-account.

resource "aws_route53_zone" "this" {
  name    = var.zone_name
  comment = var.comment

  dynamic "vpc" {
    for_each = var.vpcs
    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.region
    }
  }

  tags = merge(var.tags, { Name = var.zone_name })

  # SEM ISTO O PRÓXIMO APPLY DESFAZ O TRABALHO DA OUTRA CONTA: quando ela roda
  # associate-vpc-with-hosted-zone, a VPC dela passa a constar na zona; o Terraform lê isso
  # como drift e, no apply seguinte, DESASSOCIA em silêncio. A associação cross-account é,
  # por construção, feita fora deste state. Para associar VPC própria depois da criação,
  # use var.additional_vpcs (aws_route53_zone_association), que não conflita com isso.
  lifecycle {
    ignore_changes = [vpc]

    precondition {
      condition     = length(var.vpcs) > 0
      error_message = "Zona privada exige ao menos uma VPC associada."
    }
  }
}

resource "aws_route53_zone_association" "additional" {
  for_each = var.additional_vpcs

  zone_id    = aws_route53_zone.this.zone_id
  vpc_id     = each.value.vpc_id
  vpc_region = each.value.region
}

# CNAME para endereços gerenciados pela AWS (*.elb.amazonaws.com, *.rds.amazonaws.com,
# *.cache.amazonaws.com). Aponte sempre para o NOME, nunca para o IP: o IP de um RDS muda
# em failover e o de um ALB muda a qualquer momento.
resource "aws_route53_record" "cname" {
  for_each = var.cname_records

  zone_id = aws_route53_zone.this.zone_id
  name    = "${each.key}.${var.zone_name}"
  type    = "CNAME"
  ttl     = var.ttl
  records = [each.value]
}

# Registros A para serviços com IP fixo (ex.: ENIs reservadas, appliances).
resource "aws_route53_record" "a" {
  for_each = var.a_records

  zone_id = aws_route53_zone.this.zone_id
  name    = "${each.key}.${var.zone_name}"
  type    = "A"
  ttl     = var.ttl
  records = each.value
}

# Autoriza (NÃO associa) VPCs de outras contas. A associação é um comando na conta delas —
# veja o output cross_account_commands.
resource "aws_route53_vpc_association_authorization" "cross_account" {
  for_each = var.cross_account_vpcs

  zone_id    = aws_route53_zone.this.zone_id
  vpc_id     = each.value.vpc_id
  vpc_region = each.value.region
}
