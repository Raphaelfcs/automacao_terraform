# Exemplo "basico" do módulo aws/iam-mfa-audit: Auditoria de MFA.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "iam_mfa_audit" {
  source = "../.."

  name_prefix     = local.name_prefix
  alert_topic_arn = "arn:aws:sns:sa-east-1:123456789012:demo-dev-alertas"
  tags            = local.tags
}
