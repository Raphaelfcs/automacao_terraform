output "group_ids" {
  description = "ID de cada grupo no Identity Store."
  value       = { for k, g in aws_identitystore_group.this : k => g.group_id }
}

output "user_ids" {
  description = "ID de cada usuário no Identity Store."
  value       = { for k, u in aws_identitystore_user.this : k => u.user_id }
}

output "identity_store_id" {
  description = "ID do Identity Store."
  value       = local.identity_store_id
}
