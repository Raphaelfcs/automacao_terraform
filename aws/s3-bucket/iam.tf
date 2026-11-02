data "aws_iam_policy_document" "this" {
  # Curinga em Deny restringe: enumerar ações num Deny deixa buracos.
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.this.arn, "${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # Leitura entre contas (opcional).
  dynamic "statement" {
    for_each = length(var.read_principal_arns) > 0 ? [1] : []
    content {
      sid       = "CrossAccountRead"
      actions   = ["s3:GetObject", "s3:ListBucket"]
      resources = [aws_s3_bucket.this.arn, "${aws_s3_bucket.this.arn}/*"]
      principals {
        type        = "AWS"
        identifiers = var.read_principal_arns
      }
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json

  depends_on = [aws_s3_bucket_public_access_block.this]
}
