# Exemplo "aws-e-gcp" do módulo aws/route53-health-routing: DNS ativo-ativo entre nuvens com health check.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "route53_health_routing" {
  source = "../.."

  zone_id     = "Z0123456789ABCDEFGHIJ"
  record_name = "app.example.com"
  endpoints = {
    aws = { alias = { name = "d111111abcdef8.cloudfront.net", zone_id = "Z2FDTNDATAQYW2" }, health_fqdn = "d111111abcdef8.cloudfront.net" }
    gcp = { ips = ["34.120.0.10"], health_fqdn = "app.example.com", health_ip = "34.120.0.10" }
  }
  tags = local.tags
}
