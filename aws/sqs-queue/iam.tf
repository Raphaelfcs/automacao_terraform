resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  for_each = aws_sqs_queue.dlq

  queue_url = each.value.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this[each.key].arn]
  })
}

# TLS obrigatório e, opcionalmente, envio permitido a tópicos SNS/regras informados.
data "aws_iam_policy_document" "queue" {
  for_each = aws_sqs_queue.this

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["sqs:*"]
    resources = [each.value.arn]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = length(var.allowed_source_arns) > 0 ? [1] : []
    content {
      sid       = "AllowSources"
      actions   = ["sqs:SendMessage"]
      resources = [each.value.arn]
      principals {
        type        = "Service"
        identifiers = ["sns.amazonaws.com", "events.amazonaws.com", "s3.amazonaws.com"]
      }
      condition {
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = var.allowed_source_arns
      }
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  for_each = aws_sqs_queue.this

  queue_url = each.value.id
  policy    = data.aws_iam_policy_document.queue[each.key].json
}
