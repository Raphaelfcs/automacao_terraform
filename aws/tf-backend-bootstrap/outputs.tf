output "state_bucket_name" {
  description = "Bucket de estado (use no backend.tf dos stacks)."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN do bucket (para políticas das roles de CI)."
  value       = aws_s3_bucket.state.arn
}

output "lock_table_name" {
  description = "Tabela de lock (null quando desligada)."
  value       = try(aws_dynamodb_table.lock[0].name, null)
}

output "backend_snippet" {
  description = "Trecho de backend.tf pronto para os stacks."
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket       = "${aws_s3_bucket.state.id}"
        key          = "<projeto>/<ambiente>/<recurso>.tfstate"
        region       = "<regiao>"
        encrypt      = true
        use_lockfile = true
      }
    }
  EOT
}
