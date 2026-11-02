output "input_bucket" {
  description = "Bucket de entrada."
  value       = module.input.bucket_name
}

output "output_bucket" {
  description = "Bucket com os JSONs extraídos."
  value       = module.output.bucket_name
}

output "function_arn" {
  description = "ARN da função."
  value       = module.function.function_arn
}
