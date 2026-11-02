output "vpc_id" {
  description = "ID da VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR da VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas, na ordem de var.azs."
  value       = [for az in var.azs : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas, na ordem de var.azs."
  value       = [for az in var.azs : aws_subnet.private[az].id]
}

output "data_subnet_ids" {
  description = "IDs das subnets de dados (vazio se create_data_subnets = false)."
  value       = [for az in var.azs : aws_subnet.data[az].id if var.create_data_subnets]
}

output "private_route_table_ids" {
  description = "Tabelas de rota privadas (para rotas de TGW/VPN adicionadas por outros módulos)."
  value       = aws_route_table.private[*].id
}

output "data_route_table_ids" {
  description = "Tabelas de rota da camada de dados."
  value       = aws_route_table.data[*].id
}

output "nat_public_ips" {
  description = "IPs públicos dos NAT Gateways (para allowlist em parceiros)."
  value       = aws_eip.nat[*].public_ip
}
