# Exemplo "basico" do módulo aws/eks-argocd: Argo CD bootstrap (GitOps).
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

data "aws_eks_cluster" "this" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = local.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

variable "gitops_repo_ssh_key" {
  description = "Valor sensível informado via TF_VAR_gitops_repo_ssh_key ou cofre de segredos."
  type        = string
  sensitive   = true
}

module "eks_argocd" {
  source = "../.."

  gitops_repo_url       = "git@github.com:minha-org/gitops.git"
  gitops_repo_ssh_key   = var.gitops_repo_ssh_key
  gitops_bootstrap_path = "clusters/dev"
  hostname              = "argocd.dev.example.com"
}
