# Exemplo "eventbridge-e-sns" do módulo aws/kms-key: Chave KMS (CMK) da plataforma.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "kms_key" {
  source = "../.."

  name_prefix            = local.name_prefix
  event_rule_arns        = ["arn:aws:events:sa-east-1:123456789012:rule/demo-bus/demo-regra"]
  service_principals     = ["sns.amazonaws.com"]
  key_administrator_arns = ["arn:aws:iam::123456789012:role/platform-admin"]
  tags                   = local.tags
}
