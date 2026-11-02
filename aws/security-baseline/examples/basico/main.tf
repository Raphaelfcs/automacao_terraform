# Exemplo "basico" do módulo aws/security-baseline: Baseline de segurança da organização.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "security_baseline" {
  source = "../.."

  tags = local.tags
}
