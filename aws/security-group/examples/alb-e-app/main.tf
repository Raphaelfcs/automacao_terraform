# Exemplo "alb-e-app" do módulo aws/security-group: Security group declarativo.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "security_group" {
  source = "../.."

  name        = "demo-dev-app"
  description = "App atras do ALB"
  vpc_id      = "vpc-0123456789abcdef0"
  ingress_rules = {
    "http-do-alb"   = { from_port = 8080, source_security_group_id = "sg-0aaaaaaaaaaaaaaaa" }
    "https-publico" = { from_port = 443, cidr_ipv4 = "0.0.0.0/0" }
  }
  tags = local.tags
}
