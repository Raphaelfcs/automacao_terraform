locals {
  bucket_name = var.create_bucket ? aws_s3_bucket.this[0].id : var.bucket_name
  bucket_arn  = "arn:aws:s3:::${local.bucket_name}"
}
