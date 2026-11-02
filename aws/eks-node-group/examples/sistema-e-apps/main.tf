# Exemplo "sistema-e-apps" do módulo aws/eks-node-group: Node groups EKS com launch template.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "eks_node_group" {
  source = "../.."

  cluster_name            = "demo-dev"
  node_role_arn           = "arn:aws:iam::123456789012:role/demo-dev-node"
  subnet_ids              = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
  node_security_group_ids = ["sg-0123456789abcdef0"]
  kms_key_arn             = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  node_groups = {
    system = { instance_types = ["t3.medium"], desired_size = 2, min_size = 1, max_size = 3, taints = [{ key = "CriticalAddonsOnly", value = "true", effect = "NO_SCHEDULE" }] }
    apps   = { instance_types = ["m7i.large", "m6i.large"], capacity_type = "SPOT", desired_size = 2, min_size = 0, max_size = 10, disk_size = 100, cluster_autoscaler = true }
  }
  tags = local.tags
}
