# Exemplo "validacao-gcp" do módulo aws/route53-records: Registros DNS avulsos no Route 53.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "route53_records" {
  source = "../.."

  zone_id = "Z0123456789ABCDEFGHIJ"
  records = {
    gcp-cert = { name = "_acme-challenge.app.example.com.", type = "CNAME", values = ["abc.1.authorize.certificatemanager.goog."] }
  }
}
