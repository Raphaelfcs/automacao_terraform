# Exemplo "ssm-ecr" do módulo aws/vpc-endpoints: VPC Endpoints Interface/Gateway.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "vpc_endpoints" {
  source = "../.."

  name_prefix        = local.name_prefix
  vpc_id             = "vpc-0123456789abcdef0"
  subnet_ids         = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
  route_table_ids    = ["rtb-0aaa1111bbbb2222c"]
  interface_services = ["ssm", "ssmmessages", "ec2messages", "ecr.api", "ecr.dkr", "logs", "sts"]
  tags               = local.tags
}
