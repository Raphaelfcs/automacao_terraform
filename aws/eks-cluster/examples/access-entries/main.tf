# Exemplo "access-entries" do módulo aws/eks-cluster: Cluster EKS privado.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "eks_cluster" {
  source = "../.."

  cluster_name            = "demo-prd"
  kubernetes_version      = "1.31"
  subnet_ids              = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
  kms_key_arn             = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  bootstrap_creator_admin = false
  access_entries = {
    plataforma = { principal_arn = "arn:aws:iam::123456789012:role/AWSReservedSSO_PlatformAdmin_abc123", policy = "AmazonEKSClusterAdminPolicy" }
    leitura    = { principal_arn = "arn:aws:iam::123456789012:role/AWSReservedSSO_ReadOnly_def456", policy = "AmazonEKSViewPolicy", namespaces = ["apps"] }
  }
  pre_node_addons            = ["vpc-cni"]
  addon_configuration_values = { "vpc-cni" = jsonencode({ env = { WARM_IP_TARGET = "2" } }) }
  tags                       = local.tags
}
