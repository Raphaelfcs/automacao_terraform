# Exemplo "basico" do módulo aws/cur-focus-export: Exportação de custos FOCUS 1.0.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "cur_focus_export" {
  source = "../.."

  bucket_name    = "demo-finops-focus-123456789012"
  retention_days = 730
  tags           = local.tags
}
