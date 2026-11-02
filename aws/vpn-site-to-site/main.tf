############################################
# Customer Gateway — criado apenas para VPNs com customer_gateway.mode = "new".
# Para mode = "existing", nenhum recurso é criado aqui — reaproveitamos o ID
# informado (ver local.customer_gateway_ids em locals.tf).
############################################
resource "aws_customer_gateway" "this" {
  for_each = local.new_customer_gateways

  bgp_asn          = each.value.customer_gateway.bgp_asn
  bgp_asn_extended = each.value.customer_gateway.bgp_asn_extended
  ip_address       = each.value.customer_gateway.ip_address
  certificate_arn  = each.value.customer_gateway.certificate_arn
  device_name      = each.value.customer_gateway.device_name
  type             = "ipsec.1"

  tags = merge(
    local.common_tags,
    each.value.tags,
    { Name = "cgw-${each.key}" }
  )
}

############################################
# VPN Connection (Site-to-Site) — um por VPN em var.vpn_connections.
#
# O attachment no gateway de destino (TGW, VGW ou VPN Concentrator) é criado
# automaticamente pela AWS junto com este recurso quando target_gateway_type
# aponta para um deles; quando target_gateway_type = "not_associated", a VPN
# fica sem attachment (customer gateway configurado, mas sem lado AWS conectado).
#
# Este módulo nunca cria/gerencia o TGW, VGW ou VPN Concentrator em si — apenas
# referencia os IDs já existentes informados em cada VPN.
############################################
resource "aws_vpn_connection" "this" {
  for_each = var.vpn_connections

  customer_gateway_id = local.customer_gateway_ids[each.key]
  type                = "ipsec.1"

  transit_gateway_id  = each.value.target_gateway_type == "transit_gateway" ? each.value.transit_gateway_id : null
  vpn_gateway_id      = each.value.target_gateway_type == "virtual_private_gateway" ? each.value.vpn_gateway_id : null
  vpn_concentrator_id = each.value.target_gateway_type == "vpn_concentrator" ? each.value.vpn_concentrator_id : null

  transport_transit_gateway_attachment_id = each.value.transport_transit_gateway_attachment_id

  static_routes_only = each.value.routing_option == "static"

  outside_ip_address_type = each.value.outside_ip_address_type

  # preshared_key_storage, tunnel_bandwidth, tunnel_inside_ip_version e
  # enable_acceleration só são aceitos pela AWS quando a VPN está anexada a um
  # Transit Gateway — todos têm default não-nulo no módulo (então seriam
  # enviados mesmo sem o usuário pedir nada), e o provider rejeita a requisição
  # com "conflicts with vpn_gateway_id"/"must be specified together with
  # transit_gateway_id" quando target_gateway_type é virtual_private_gateway,
  # vpn_concentrator ou not_associated. Confirmado em erro real do provider
  # para enable_acceleration e tunnel_bandwidth; tratamos os quatro campos da
  # mesma família de forma conservadora até termos confirmação em contrário.
  preshared_key_storage    = each.value.target_gateway_type == "transit_gateway" ? each.value.preshared_key_storage : null
  tunnel_bandwidth         = each.value.target_gateway_type == "transit_gateway" ? each.value.tunnel_bandwidth : null
  tunnel_inside_ip_version = each.value.target_gateway_type == "transit_gateway" ? each.value.tunnel_inside_ip_version : null
  enable_acceleration      = each.value.target_gateway_type == "transit_gateway" ? each.value.enable_acceleration : null

  local_ipv4_network_cidr  = each.value.local_ipv4_network_cidr
  remote_ipv4_network_cidr = each.value.remote_ipv4_network_cidr
  local_ipv6_network_cidr  = each.value.local_ipv6_network_cidr
  remote_ipv6_network_cidr = each.value.remote_ipv6_network_cidr

  # --- Tunnel 1 ---
  tunnel1_inside_cidr      = each.value.tunnel1.inside_cidr
  tunnel1_inside_ipv6_cidr = each.value.tunnel1.inside_ipv6_cidr
  tunnel1_preshared_key    = each.value.tunnel1.preshared_key

  tunnel1_ike_versions = each.value.tunnel1.ike_versions

  tunnel1_phase1_encryption_algorithms = each.value.tunnel1.phase1_encryption_algorithms
  tunnel1_phase2_encryption_algorithms = each.value.tunnel1.phase2_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = each.value.tunnel1.phase1_integrity_algorithms
  tunnel1_phase2_integrity_algorithms  = each.value.tunnel1.phase2_integrity_algorithms
  tunnel1_phase1_dh_group_numbers      = each.value.tunnel1.phase1_dh_group_numbers
  tunnel1_phase2_dh_group_numbers      = each.value.tunnel1.phase2_dh_group_numbers

  tunnel1_phase1_lifetime_seconds = each.value.tunnel1.phase1_lifetime_seconds
  tunnel1_phase2_lifetime_seconds = each.value.tunnel1.phase2_lifetime_seconds

  tunnel1_rekey_margin_time_seconds = each.value.tunnel1.rekey_margin_time_seconds
  tunnel1_rekey_fuzz_percentage     = each.value.tunnel1.rekey_fuzz_percentage
  tunnel1_replay_window_size        = each.value.tunnel1.replay_window_size

  tunnel1_dpd_timeout_seconds = each.value.tunnel1.dpd_timeout_seconds
  tunnel1_dpd_timeout_action  = each.value.tunnel1.dpd_timeout_action
  tunnel1_startup_action      = each.value.tunnel1.startup_action

  tunnel1_enable_tunnel_lifecycle_control = each.value.tunnel1.enable_tunnel_lifecycle_control

  dynamic "tunnel1_log_options" {
    for_each = (each.value.tunnel1.log.activity_log_enabled || each.value.tunnel1.log.bgp_log_enabled) ? [1] : []
    content {
      cloudwatch_log_options {
        log_enabled           = each.value.tunnel1.log.activity_log_enabled
        log_group_arn         = each.value.tunnel1.log.activity_log_group_arn
        log_output_format     = each.value.tunnel1.log.activity_log_output_format
        bgp_log_enabled       = each.value.tunnel1.log.bgp_log_enabled
        bgp_log_group_arn     = each.value.tunnel1.log.bgp_log_group_arn
        bgp_log_output_format = each.value.tunnel1.log.bgp_log_output_format
      }
    }
  }

  # --- Tunnel 2 ---
  tunnel2_inside_cidr      = each.value.tunnel2.inside_cidr
  tunnel2_inside_ipv6_cidr = each.value.tunnel2.inside_ipv6_cidr
  tunnel2_preshared_key    = each.value.tunnel2.preshared_key

  tunnel2_ike_versions = each.value.tunnel2.ike_versions

  tunnel2_phase1_encryption_algorithms = each.value.tunnel2.phase1_encryption_algorithms
  tunnel2_phase2_encryption_algorithms = each.value.tunnel2.phase2_encryption_algorithms
  tunnel2_phase1_integrity_algorithms  = each.value.tunnel2.phase1_integrity_algorithms
  tunnel2_phase2_integrity_algorithms  = each.value.tunnel2.phase2_integrity_algorithms
  tunnel2_phase1_dh_group_numbers      = each.value.tunnel2.phase1_dh_group_numbers
  tunnel2_phase2_dh_group_numbers      = each.value.tunnel2.phase2_dh_group_numbers

  tunnel2_phase1_lifetime_seconds = each.value.tunnel2.phase1_lifetime_seconds
  tunnel2_phase2_lifetime_seconds = each.value.tunnel2.phase2_lifetime_seconds

  tunnel2_rekey_margin_time_seconds = each.value.tunnel2.rekey_margin_time_seconds
  tunnel2_rekey_fuzz_percentage     = each.value.tunnel2.rekey_fuzz_percentage
  tunnel2_replay_window_size        = each.value.tunnel2.replay_window_size

  tunnel2_dpd_timeout_seconds = each.value.tunnel2.dpd_timeout_seconds
  tunnel2_dpd_timeout_action  = each.value.tunnel2.dpd_timeout_action
  tunnel2_startup_action      = each.value.tunnel2.startup_action

  tunnel2_enable_tunnel_lifecycle_control = each.value.tunnel2.enable_tunnel_lifecycle_control

  dynamic "tunnel2_log_options" {
    for_each = (each.value.tunnel2.log.activity_log_enabled || each.value.tunnel2.log.bgp_log_enabled) ? [1] : []
    content {
      cloudwatch_log_options {
        log_enabled           = each.value.tunnel2.log.activity_log_enabled
        log_group_arn         = each.value.tunnel2.log.activity_log_group_arn
        log_output_format     = each.value.tunnel2.log.activity_log_output_format
        bgp_log_enabled       = each.value.tunnel2.log.bgp_log_enabled
        bgp_log_group_arn     = each.value.tunnel2.log.bgp_log_group_arn
        bgp_log_output_format = each.value.tunnel2.log.bgp_log_output_format
      }
    }
  }

  tags = merge(
    local.common_tags,
    each.value.tags,
    { Name = coalesce(each.value.name_tag, "vpn-${each.key}") }
  )
}

############################################
# Rotas estáticas do lado da VPN (somente para VPNs com routing_option = "static").
# Isso é o que a AWS anuncia para o gateway de destino via propagação — não mexe
# em rotas estáticas de outras VPNs/attachments.
############################################
resource "aws_vpn_connection_route" "this" {
  for_each = local.static_routes_map

  destination_cidr_block = each.value.cidr
  vpn_connection_id      = aws_vpn_connection.this[each.value.vpn_key].id
}

############################################
# Associação do(s) NOVO(S) attachment(s) de VPN (target_gateway_type = "transit_gateway")
# a uma TGW route table existente. Recurso aditivo: associa apenas o attachment
# desta VPN, sem tocar em associações de outros attachments já existentes na
# mesma route table.
############################################
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = local.manage_tgw_route_table ? local.tgw_attached_vpns : {}

  transit_gateway_attachment_id  = aws_vpn_connection.this[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

############################################
# Propagação das rotas do(s) NOVO(S) attachment(s) para a mesma TGW route table.
# Também aditivo: apenas adiciona a propagação deste attachment; rotas propagadas
# por outros attachments (VPCs, outras VPNs, DX) permanecem intocadas.
############################################
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = local.manage_tgw_route_table ? local.tgw_attached_vpns : {}

  transit_gateway_attachment_id  = aws_vpn_connection.this[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id

  depends_on = [aws_ec2_transit_gateway_route_table_association.this]
}

# Este é um módulo filho (child module) — propositalmente NÃO existe aqui um bloco
# `provider "aws" { ... }` com region/profile/credenciais.
#
# Prática recomendada pela HashiCorp: módulos reutilizáveis não configuram provider,
# apenas declaram os requisitos em `required_providers`. Quem configura region,
# profile, assume_role etc. é sempre o módulo raiz (root module) que consome este
# módulo — veja o provider.tf dentro de infra-modules-workload/modulo_vpn_v2.
#
# A versão mínima do provider AWS foi elevada para >= 6.0 porque este módulo usa
# atributos recentes do aws_vpn_connection (vpn_concentrator_id, preshared_key_storage,
# tunnel_bandwidth, tunnel_inside_ip_version, tunnel*_log_options, bgp_asn_extended
# em aws_customer_gateway) que não existem em versões antigas do provider.
