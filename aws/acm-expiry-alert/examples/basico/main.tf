# Exemplo "basico" do módulo aws/acm-expiry-alert: Alerta de expiração de certificados.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "acm_expiry_alert" {
  source = "../.."

  name_prefix     = local.name_prefix
  alert_topic_arn = "arn:aws:sns:sa-east-1:123456789012:demo-dev-alertas"
  tags            = local.tags
}
