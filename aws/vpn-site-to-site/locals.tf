locals {
  # Tags comuns aplicadas a tudo que este módulo cria.
  common_tags = merge(var.tags, {
    ManagedBy = "terraform"
    Module    = "vpn-site-to-site"
  })

  # Só criamos um aws_customer_gateway novo para as VPNs com customer_gateway.mode = "new".
  # As demais (mode = "existing") reaproveitam um customer gateway já existente na conta.
  new_customer_gateways = { for k, v in var.vpn_connections : k => v if v.customer_gateway.mode == "new" }

  # ID do customer gateway efetivo de cada VPN, já resolvido: o recém-criado por
  # este módulo (mode = "new") ou o informado pelo chamador (mode = "existing").
  customer_gateway_ids = {
    for k, v in var.vpn_connections :
    k => v.customer_gateway.mode == "new" ? aws_customer_gateway.this[k].id : v.customer_gateway.customer_gateway_id
  }

  # Flag: só gerenciamos associação/propagação na TGW route table se o chamador
  # informou explicitamente um transit_gateway_route_table_id.
  manage_tgw_route_table = var.transit_gateway_route_table_id != null

  # Só as VPNs ancoradas num Transit Gateway participam de association/propagation
  # na TGW route table — VPNs com virtual_private_gateway/vpn_concentrator/not_associated
  # não têm um transit_gateway_attachment_id de VPN para associar ali.
  tgw_attached_vpns = { for k, v in var.vpn_connections : k => v if v.target_gateway_type == "transit_gateway" }

  # Achata var.vpn_connections em uma lista de { vpn_key, cidr } — uma linha por
  # rota estática de cada VPN com routing_option = "static". Necessário porque
  # aws_vpn_connection_route é 1 recurso por CIDR, não por VPN.
  static_routes_flat = flatten([
    for vpn_key, vpn in var.vpn_connections : [
      for cidr in vpn.static_routes : {
        vpn_key = vpn_key
        cidr    = cidr
      }
    ] if vpn.routing_option == "static"
  ])

  # Reindexado como mapa (chave estável "vpnkey|cidr") para uso em for_each.
  static_routes_map = {
    for r in local.static_routes_flat : "${r.vpn_key}|${r.cidr}" => r
  }
}
