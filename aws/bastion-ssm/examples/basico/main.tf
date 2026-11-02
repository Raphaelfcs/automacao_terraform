# Exemplo "basico" do módulo aws/bastion-ssm: Bastion SSM-only para EKS privado.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "bastion_ssm" {
  source = "../.."

  environment       = "dev"
  cluster_name      = "demo-dev"
  vpc_id            = "vpc-0123456789abcdef0"
  private_subnet_id = "subnet-0aaa1111bbbb2222c"
  eks_cluster_sg_id = "sg-0123456789abcdef0"
  kubectl_version   = "v1.31.2"
  enable_helm       = true
  enable_k9s        = true
  tags              = local.tags
}
