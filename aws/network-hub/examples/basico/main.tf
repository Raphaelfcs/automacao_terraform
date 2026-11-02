# Exemplo "basico" do módulo aws/network-hub: Conta Network hub-and-spoke.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "network_hub" {
  source = "../.."

  share_with_principals = ["arn:aws:organizations::123456789012:organization/o-exemplo123"]
  tags                  = local.tags
}
