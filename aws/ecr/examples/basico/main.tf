# Exemplo "basico" do módulo aws/ecr: Repositórios ECR com scan, KMS e retenção.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "ecr" {
  source = "../.."

  name_prefix      = "demo"
  repository_names = ["api", "worker"]
  tags             = local.tags
}
