# Exemplo "zona-com-wildcard" do módulo aws/route53-public-zone: subdomínio de dev com
# certificado curinga. A validação conclui depois que a delegação NS existir na zona pai.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "dns_dev" {
  source = "../.."

  zone_name                   = "dev.example.com"
  create_wildcard_certificate = true
  wait_for_validation         = false
  tags                        = local.tags
}

output "name_servers" {
  value = module.dns_dev.name_servers
}
