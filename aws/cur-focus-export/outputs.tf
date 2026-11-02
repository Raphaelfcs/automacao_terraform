output "export_arn" {
  description = "ARN da exportação FOCUS."
  value       = aws_bcmdataexports_export.focus.id
}

output "bucket_name" {
  description = "Bucket com os arquivos Parquet."
  value       = local.bucket_name
}

output "athena_location" {
  description = "Local S3 para criar a tabela no Athena/Glue."
  value       = "s3://${local.bucket_name}/${var.s3_prefix}/${var.export_name}/data/"
}
