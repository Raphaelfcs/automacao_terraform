output "bucket_name" {
  description = "Nome do bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN do bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_regional_domain_name" {
  description = "Domínio regional (origem de CloudFront)."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
