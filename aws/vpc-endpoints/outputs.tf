output "interface_endpoint_ids" {
  description = "Mapa serviço -> ID do Interface endpoint."
  value       = { for k, e in aws_vpc_endpoint.interface : k => e.id }
}

output "gateway_endpoint_ids" {
  description = "Mapa serviço -> ID do Gateway endpoint."
  value       = { for k, e in aws_vpc_endpoint.gateway : k => e.id }
}

output "security_group_id" {
  description = "SG compartilhado dos Interface endpoints."
  value       = try(aws_security_group.endpoints[0].id, null)
}
