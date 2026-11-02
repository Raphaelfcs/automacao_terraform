data "aws_iam_policy_document" "function" {
  statement {
    sid       = "ReadIam"
    actions   = ["iam:GetAccountAuthorizationDetails"]
    resources = ["*"]
  }

  statement {
    sid       = "Write"
    actions   = ["s3:PutObject"]
    resources = ["${module.bucket.bucket_arn}/iam-inventario/*"]
  }

  dynamic "statement" {
    for_each = var.kms_key_arn == null ? [] : [var.kms_key_arn]
    content {
      sid       = "Kms"
      actions   = ["kms:GenerateDataKey"]
      resources = [statement.value]
    }
  }
}
