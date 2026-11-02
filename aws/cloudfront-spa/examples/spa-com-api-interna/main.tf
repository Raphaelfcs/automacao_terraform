# Exemplo "spa-com-api-interna" do módulo aws/cloudfront-spa: SPA em S3 + CloudFront.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "cloudfront_spa" {
  source = "../.."

  name_prefix            = local.name_prefix
  app_name               = "portal"
  dist_path              = "${path.module}/dist"
  aliases                = ["portal.example.com"]
  acm_certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-2222-3333-4444-555555555555"
  web_acl_id             = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/demo/abc"
  api_vpc_origin_enabled = true
  api_vpc_origin_arn     = "arn:aws:elasticloadbalancing:sa-east-1:123456789012:loadbalancer/app/api/0123456789abcdef"
  api_vpc_origin_domain  = "internal-api-123.sa-east-1.elb.amazonaws.com"
  tags                   = local.tags
}
