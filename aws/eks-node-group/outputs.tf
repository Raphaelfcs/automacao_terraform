output "node_group_names" {
  description = "Mapa chave -> nome do node group."
  value       = { for k, ng in aws_eks_node_group.this : k => ng.node_group_name }
}

output "node_groups_status" {
  description = "Status de cada node group — use como âncora de depends_on para addons."
  value       = { for k, ng in aws_eks_node_group.this : k => ng.status }
}

output "launch_template_ids" {
  description = "Mapa chave -> ID do launch template."
  value       = { for k, lt in aws_launch_template.this : k => lt.id }
}
