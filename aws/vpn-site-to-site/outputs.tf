output "customer_gateway_ids" {
  description = "Mapa { chave_da_vpn => id do Customer Gateway efetivo (criado por este módulo ou existente reaproveitado)}."
  value       = local.customer_gateway_ids
}

output "vpn_connection_ids" {
  description = "Mapa { chave_da_vpn => id da VPN Connection }."
  value       = { for k, v in aws_vpn_connection.this : k => v.id }
}

output "transit_gateway_attachment_ids" {
  description = "Mapa { chave_da_vpn => id do Transit Gateway Attachment }, apenas para VPNs com target_gateway_type = \"transit_gateway\"."
  value       = { for k, v in aws_vpn_connection.this : k => v.transit_gateway_attachment_id if var.vpn_connections[k].target_gateway_type == "transit_gateway" }
}

output "preshared_key_arns" {
  description = "Mapa { chave_da_vpn => ARN da PSK no Secrets Manager }, apenas para VPNs com preshared_key_storage = \"SecretsManager\"."
  value       = { for k, v in aws_vpn_connection.this : k => v.preshared_key_arn if var.vpn_connections[k].preshared_key_storage == "SecretsManager" }
}

output "vpn_connections" {
  description = <<-EOT
    Mapa completo { chave_da_vpn => detalhes da VPN }, incluindo os endereços
    públicos AWS de cada túnel e as pre-shared keys (geradas pela AWS quando
    não informadas em var.vpn_connections, ou vazias quando preshared_key_storage
    = "SecretsManager" — nesse caso use o output preshared_key_arns). Use estes
    dados para configurar o equipamento do outro lado (firewall, roteador etc.).
  EOT
  sensitive   = true
  value = {
    for k, v in aws_vpn_connection.this : k => {
      vpn_connection_id     = v.id
      customer_gateway_id   = local.customer_gateway_ids[k]
      tunnel1_address       = v.tunnel1_address
      tunnel2_address       = v.tunnel2_address
      tunnel1_inside_cidr   = v.tunnel1_inside_cidr
      tunnel2_inside_cidr   = v.tunnel2_inside_cidr
      tunnel1_preshared_key = v.tunnel1_preshared_key
      tunnel2_preshared_key = v.tunnel2_preshared_key
    }
  }
}

output "customer_gateway_configuration" {
  description = "Mapa { chave_da_vpn => XML de configuração completo gerado pela AWS para essa VPN (contém PSKs)."
  sensitive   = true
  value       = { for k, v in aws_vpn_connection.this : k => v.customer_gateway_configuration }
}
