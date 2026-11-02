output "attachment_id" {
  description = "ID do attachment (null quando desligado)."
  value       = try(aws_ec2_transit_gateway_vpc_attachment.this[0].id, null)
}

output "route_ids" {
  description = "Rotas criadas por chave tabela-cidr."
  value       = { for k, r in aws_route.remote : k => r.id }
}
