output "arn" {
  description = "ARN da Web ACL (web_acl_id da CloudFront)."
  value       = aws_wafv2_web_acl.this.arn
}

output "id" {
  description = "ID da Web ACL."
  value       = aws_wafv2_web_acl.this.id
}
