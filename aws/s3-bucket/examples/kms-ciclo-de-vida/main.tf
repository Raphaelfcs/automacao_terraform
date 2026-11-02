# Exemplo "kms-ciclo-de-vida" do módulo aws/s3-bucket: Bucket S3 seguro por padrão.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "s3_bucket" {
  source = "../.."

  bucket_name = "demo-dev-capturas-123456789012"
  kms_key_arn = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  versioning  = false
  lifecycle_rules = {
    capturas = { prefix = "captures/", expiration_days = 7 }
    arquivo  = { prefix = "arquivo/", transition_days = 30, transition_storage_class = "GLACIER_IR" }
  }
  tags = local.tags
}
