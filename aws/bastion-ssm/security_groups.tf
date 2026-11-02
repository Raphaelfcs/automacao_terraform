# ── Security Group do bastion ─────────────────────────────────────────────────
#
# ZERO regras de ingress, de propósito. O único caminho de acesso é o agente SSM,
# que abre uma conexão de SAÍDA para o serviço SSM — não existe caminho de entrada
# para esta instância. Um SG sem ingress aqui NÃO é um bug de revisão: é o requisito
# central deste módulo.
resource "aws_security_group" "bastion" {
  name        = "${var.cluster_name}-bastion-sg"
  description = "Bastion SSM-only - sem regra de ingress. Acesso exclusivo via Session Manager."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.cluster_name}-bastion-sg" })
}

# Egress padrão: toda saída (o agente SSM conecta para FORA, via NAT ou VPC endpoints
# ssm/ssmmessages/ec2messages). Só existe quando restrict_egress = false.
resource "aws_vpc_security_group_egress_rule" "bastion_all_outbound" {
  count = var.restrict_egress ? 0 : 1

  security_group_id = aws_security_group.bastion.id
  description       = "All outbound - egress via NAT ou VPC endpoints"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ── Egress restrito (var.restrict_egress = true) ─────────────────────────────
resource "aws_vpc_security_group_egress_rule" "bastion_https_public" {
  count = var.restrict_egress ? 1 : 0

  security_group_id = aws_security_group.bastion.id
  description       = "HTTPS outbound - SSM, dl.k8s.io, awscliv2 installer, dnf mirrors"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "bastion_http_public" {
  count = var.restrict_egress ? 1 : 0

  security_group_id = aws_security_group.bastion.id
  description       = "HTTP outbound - alguns mirrors dnf/AL2023 ainda usam HTTP"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_eks" {
  count = var.restrict_egress ? 1 : 0

  security_group_id            = aws_security_group.bastion.id
  description                  = "HTTPS to EKS API endpoint"
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = var.eks_cluster_sg_id
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_rds" {
  count = var.restrict_egress && var.rds_security_group_id != null ? 1 : 0

  security_group_id            = aws_security_group.bastion.id
  description                  = "PostgreSQL to RDS"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = var.rds_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_redis" {
  count = var.restrict_egress && var.redis_security_group_id != null ? 1 : 0

  security_group_id            = aws_security_group.bastion.id
  description                  = "Redis to ElastiCache"
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  referenced_security_group_id = var.redis_security_group_id
}

# ── Regra standalone em SG de terceiro (módulo eks) ───────────────────────────
#
# Único ingress criado por este módulo, no SG do control plane EKS (ID recebido por
# variável), liberando 443 a partir do bastion.
resource "aws_vpc_security_group_ingress_rule" "eks_from_bastion" {
  security_group_id            = var.eks_cluster_sg_id
  referenced_security_group_id = aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "HTTPS from bastion to EKS API - cluster_endpoint_private_access resolve para IPs privados das ENIs, sem depender de trusted_cidr_blocks"
}
