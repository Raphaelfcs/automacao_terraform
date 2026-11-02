# Exportação de custos no padrão FOCUS 1.0 (FinOps Open Cost & Usage Specification) via
# AWS Data Exports para S3 em Parquet, base para Athena/QuickSight ou ferramentas FinOps.
# Substitui o antigo CUR legado. A API do Data Exports (bcm-data-exports) só existe em us-east-1.

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "this" {
  count = var.create_bucket ? 1 : 0

  bucket        = var.bucket_name
  force_destroy = false
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.create_bucket ? 1 : 0

  bucket                  = aws_s3_bucket.this[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.create_bucket && var.retention_days > 0 ? 1 : 0

  bucket = aws_s3_bucket.this[0].id
  rule {
    id     = "expirar-exports"
    status = "Enabled"
    filter {}
    expiration {
      days = var.retention_days
    }
  }
}

resource "aws_bcmdataexports_export" "focus" {
  export {
    name        = var.export_name
    description = "FOCUS 1.0 - ${var.export_name}"

    data_query {
      query_statement = "SELECT ${join(", ", var.focus_columns)} FROM FOCUS_1_0_AWS"
      table_configurations = {
        FOCUS_1_0_AWS = {}
      }
    }

    destination_configurations {
      s3_destination {
        s3_bucket = local.bucket_name
        s3_prefix = var.s3_prefix
        s3_region = var.bucket_region

        s3_output_configurations {
          overwrite   = "OVERWRITE_REPORT"
          format      = "PARQUET"
          compression = "PARQUET"
          output_type = "CUSTOM"
        }
      }
    }

    refresh_cadence {
      frequency = "SYNCHRONOUS"
    }
  }

  tags = var.tags

  depends_on = [aws_s3_bucket_policy.this]
}
