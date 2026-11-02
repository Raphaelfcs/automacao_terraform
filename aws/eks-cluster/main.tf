# Cluster EKS com control plane em subnets privadas, secrets cifrados com KMS (envelope
# encryption), logs de auditoria, autenticação por Access Entries (API) e node groups
# gerenciados declarados por mapa.

data "aws_subnet" "first" {
  id = var.subnet_ids[0]
}

resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster"
  description = "Control plane do EKS ${var.cluster_name}"
  vpc_id      = data.aws_subnet.first.vpc_id

  tags = merge(var.tags, { Name = "${var.cluster_name}-cluster" })
}

resource "aws_vpc_security_group_egress_rule" "cluster_all" {
  security_group_id = aws_security_group.cluster.id
  description       = "Saida do control plane para a VPC e para a API da AWS"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.tags
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  enabled_cluster_log_types = var.cluster_log_types

  access_config {
    authentication_mode                         = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = var.bootstrap_creator_admin
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    # Sem endpoint público a lista de CIDRs não tem a que se aplicar: null, e não [].
    public_access_cidrs = var.endpoint_public_access ? var.endpoint_public_access_cidrs : null
  }

  # Service CIDR explícito só quando informado (evita sobreposição com redes corporativas).
  dynamic "kubernetes_network_config" {
    for_each = var.service_ipv4_cidr == null ? [] : [var.service_ipv4_cidr]
    content {
      service_ipv4_cidr = kubernetes_network_config.value
    }
  }

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy.cluster_encryption,
    aws_cloudwatch_log_group.cluster,
  ]
}

# IRSA: o provedor OIDC permite a um ServiceAccount assumir uma role IAM sem chave
# estática no pod. Sem ele, a anotação eks.amazonaws.com/role-arn é inerte e a chamada
# à AWS falha com "credencial ausente" — parece permissão, mas é confiança.
data "tls_certificate" "oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
