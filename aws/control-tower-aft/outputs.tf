output "repositories" {
  description = "Repositórios observados pelo AFT (crie-os privados antes do apply)."
  value       = local.repos
}

output "aft_management_account_id" {
  description = "Conta do AFT, onde ficam pipelines, filas e o estado das customizações."
  value       = var.aft_management_account_id
}

output "post_deploy" {
  description = "Passo manual depois do apply."
  value       = var.vcs_provider == "codecommit" ? "Nenhum." : "Na conta do AFT: Developer Tools > Settings > Connections > conexão Pending > Update pending connection (instale o app só nos 4 repositórios)."
}
