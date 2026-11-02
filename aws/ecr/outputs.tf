output "repository_urls" {
  description = "Mapa serviço -> URL do repositório. O pipeline usa estes valores para taguear e publicar."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}

output "repository_arns" {
  description = "Mapa serviço -> ARN do repositório."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.arn }
}
