# Exemplo "cloudfront" do módulo aws/waf-web-acl: AWS WAF com regras gerenciadas e limite por IP.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "waf_web_acl" {
  source = "../.."

  name                = "${local.name_prefix}-borda"
  allowed_countries   = ["BR"]
  rate_limit_per_5min = 1000
  tags                = local.tags
}
