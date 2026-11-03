locals {
  region       = "sa-east-1"
  cluster_name = "demo-dev"

  tags = {
    Projeto    = "demo"
    Ambiente   = "dev"
    Gerenciado = "terraform"
    Modulo     = "eks-argocd"
  }
}
