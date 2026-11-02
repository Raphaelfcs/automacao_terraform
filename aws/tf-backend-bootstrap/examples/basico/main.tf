# Exemplo "basico" do módulo aws/tf-backend-bootstrap: Bootstrap do backend S3 do Terraform.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "tf_backend_bootstrap" {
  source = "../.."

  bucket_name = "demo-tfstate-123456789012"
  tags        = local.tags
}
