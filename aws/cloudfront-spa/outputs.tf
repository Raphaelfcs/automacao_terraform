output "url" {
  description = "URL pública da SPA."
  value       = "https://${aws_cloudfront_distribution.this.domain_name}"
}

output "bucket_name" {
  description = "Bucket que guarda o build. Usado pelo pipeline para sync incremental."
  value       = aws_s3_bucket.this.bucket
}

output "distribution_id" {
  description = "ID da distribuicao. Usado pelo pipeline para invalidar o cache apos o sync."
  value       = aws_cloudfront_distribution.this.id
}

output "published_object_count" {
  description = "Quantos arquivos do dist/ foram publicados. Zero significa que o build nao rodou antes do apply."
  value       = length(aws_s3_object.dist)
}

output "domain_name" {
  description = "Domínio *.cloudfront.net da distribuicao. Compoe callback/logout do Cognito e o allowlist de CORS."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "vpc_origin_id" {
  description = "ID do CloudFront VPC origin da API (null sem origem VPC). A raiz dona do ALB libera o SG gerenciado do VPC origin."
  value       = local.has_vpc_api_origin ? aws_cloudfront_vpc_origin.api[0].id : null
}
