# Addons criados ANTES dos nós (ex.: vpc-cni com configuração de warm pool reduzida, para
# nenhum nó nascer com o CNI padrão consumindo IPs de uma subnet compartilhada).
# Só faz sentido para addon que fica ACTIVE sem nó (DaemonSet) — nunca coredns.
resource "aws_eks_addon" "pre_nodes" {
  for_each = toset(var.pre_node_addons)

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.value
  configuration_values        = lookup(var.addon_configuration_values, each.value, null)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags
}

resource "aws_eks_addon" "this" {
  for_each = setsubtract(local.managed_addons, var.pre_node_addons)

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.value
  configuration_values        = lookup(var.addon_configuration_values, each.value, null)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags

  depends_on = [aws_eks_node_group.this]
}
