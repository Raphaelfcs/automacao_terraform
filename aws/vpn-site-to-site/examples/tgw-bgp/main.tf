# Exemplo "tgw-bgp" do módulo aws/vpn-site-to-site: VPN Site-to-Site (TGW/VGW) declarativa.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "vpn_site_to_site" {
  source = "../.."

  transit_gateway_route_table_id = "tgw-rtb-0123456789abcdef0"
  vpn_connections = {
    matriz = {
      target_gateway_type = "transit_gateway"
      transit_gateway_id  = "tgw-0123456789abcdef0"
      routing_option      = "dynamic"
      customer_gateway    = { mode = "new", bgp_asn = 65010, ip_address = "203.0.113.10" }
    }
  }
  tags = local.tags
}
