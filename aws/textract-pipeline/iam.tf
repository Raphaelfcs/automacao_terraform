data "aws_iam_policy_document" "function" {
  statement {
    sid       = "Textract"
    actions   = ["textract:AnalyzeDocument", "textract:StartDocumentAnalysis", "textract:GetDocumentAnalysis"]
    resources = ["*"]
  }

  statement {
    sid       = "ReadInput"
    actions   = ["s3:GetObject"]
    resources = ["${module.input.bucket_arn}/*"]
  }

  statement {
    sid       = "WriteOutput"
    actions   = ["s3:PutObject"]
    resources = ["${module.output.bucket_arn}/*"]
  }

  dynamic "statement" {
    for_each = var.kms_key_arn == null ? [] : [var.kms_key_arn]
    content {
      sid       = "Kms"
      actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
      resources = [statement.value]
    }
  }
}
