# =============================================================================
# Saídas
# =============================================================================
output "transit_gateway_id" {
  description = "TGW compartilhado com as contas de carga e de dados."
  value       = aws_ec2_transit_gateway.this.id
}

output "route_table_ids" {
  description = "Tabelas do TGW por domínio (associe cada spoke a uma delas)."
  value       = { for k, rt in aws_ec2_transit_gateway_route_table.domain : k => rt.id }
}

output "dx_gateway_id" {
  description = "Direct Connect Gateway."
  value       = var.enable_direct_connect ? aws_dx_gateway.this[0].id : ""
}

output "resolver_inbound_ips" {
  description = "IPs para o AD local encaminhar consultas de domínios AWS."
  value       = [for ip in aws_route53_resolver_endpoint.inbound.ip_address : ip.ip]
}

output "vpn_tunnels" {
  description = "Endereços dos túneis da VPN de backup (configurar no roteador do data center)."
  value = {
    for k, v in aws_vpn_connection.this : k => [v.tunnel1_address, v.tunnel2_address]
  }
}
