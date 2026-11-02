# =============================================================================
# Saídas
# =============================================================================
output "alerts_topic_arn" {
  description = "Tópico SNS de alertas críticos de segurança."
  value       = var.enable_detection ? aws_sns_topic.alerts[0].arn : ""
}

output "guardduty_detector_id" {
  description = "Detector do GuardDuty (administrador delegado)."
  value       = var.enable_detection ? aws_guardduty_detector.this[0].id : ""
}

output "log_archive_bucket_arn" {
  description = "Bucket imutável da Log Archive (CloudTrail, Config, Flow Logs)."
  value       = var.create_log_archive_bucket ? aws_s3_bucket.logs[0].arn : ""
}
