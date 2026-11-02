# Exemplo "spa-simples" do módulo aws/cloudfront-spa: SPA em S3 + CloudFront.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "cloudfront_spa" {
  source = "../.."

  name_prefix = local.name_prefix
  app_name    = "web"
  dist_path   = "${path.module}/dist"
  tags        = local.tags
}
