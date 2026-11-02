# Exemplo "basico" do módulo aws/iam-inventory-export: Inventário IAM semanal.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "iam_inventory_export" {
  source = "../.."

  name_prefix = local.name_prefix
  bucket_name = "demo-iam-inventario-123456789012"
  tags        = local.tags
}
