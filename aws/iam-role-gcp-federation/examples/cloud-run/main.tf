# Exemplo "cloud-run" do módulo aws/iam-role-gcp-federation: Role IAM para workloads do Google Cloud sem chave.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "iam_role_gcp_federation" {
  source = "../.."

  role_name                  = "${local.name_prefix}-gcp-api"
  google_service_account_ids = ["112233445566778899001"]
  policy_json                = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query"], Resource = "arn:aws:dynamodb:sa-east-1:123456789012:table/demo-dev-itens*" }] })
  tags                       = local.tags
}
