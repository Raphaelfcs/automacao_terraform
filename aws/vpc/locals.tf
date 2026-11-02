locals {
  # CIDR fatiado em blocos iguais (newbits): públicas nos primeiros índices,
  # privadas na sequência, isoladas (dados, sem rota de saída) depois.
  n               = length(var.azs)
  public_subnets  = [for i, az in var.azs : cidrsubnet(var.cidr_block, var.subnet_newbits, i)]
  private_subnets = [for i, az in var.azs : cidrsubnet(var.cidr_block, var.subnet_newbits, i + local.n)]
  data_subnets    = [for i, az in var.azs : cidrsubnet(var.cidr_block, var.subnet_newbits, i + 2 * local.n)]

  nat_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.n) : 0

  eks_tags_public  = var.eks_cluster_name == null ? {} : { "kubernetes.io/role/elb" = "1", "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared" }
  eks_tags_private = var.eks_cluster_name == null ? {} : { "kubernetes.io/role/internal-elb" = "1", "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared" }
}
