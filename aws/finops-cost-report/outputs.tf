output "function_arn" {
  description = "ARN da função."
  value       = module.function.function_arn
}

output "bucket_name" {
  description = "Bucket dos relatórios."
  value       = module.bucket.bucket_name
}
