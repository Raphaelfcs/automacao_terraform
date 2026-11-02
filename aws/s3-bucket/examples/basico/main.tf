# Exemplo "basico" do módulo aws/s3-bucket: Bucket S3 seguro por padrão.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "s3_bucket" {
  source = "../.."

  bucket_name = "demo-dev-dados-123456789012"
  tags        = local.tags
}
