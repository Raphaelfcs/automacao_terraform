# Exemplo "basico" do módulo aws/kms-key: Chave KMS (CMK) da plataforma.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "kms_key" {
  source = "../.."

  name_prefix             = local.name_prefix
  deletion_window_in_days = 7
  tags                    = local.tags
}
