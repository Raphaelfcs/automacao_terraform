output "bucket_name" {
  description = "Bucket do inventário."
  value       = module.bucket.bucket_name
}

output "function_arn" {
  description = "ARN da função."
  value       = module.function.function_arn
}
