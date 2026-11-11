# Exemplo "cloudfront" do módulo aws/acm-certificate: Certificado ACM validado por DNS.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "acm_certificate" {
  source = "../.."

  domain_name = "app.example.com"
  zone_id     = "Z0123456789ABCDEFGHIJ"
  tags        = local.tags
}
