# Exemplo "delegar-subdominio" do módulo aws/route53-zone-delegation: na conta de produção,
# delega dev.example.com para a zona criada na conta de dev.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "delegacao_dev" {
  source = "../.."

  parent_zone_id = "Z0123456789ABCDEFGHIJ"
  subdomain      = "dev.example.com"
  name_servers   = ["ns-1.awsdns-01.org", "ns-2.awsdns-02.co.uk", "ns-3.awsdns-03.com", "ns-4.awsdns-04.net"]
}
