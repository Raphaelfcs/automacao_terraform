# Barramento: só o principal produtor, da conta produtora, com o source/detail-type combinado.
data "aws_iam_policy_document" "bus" {
  statement {
    sid       = "ProducerPutEvents"
    actions   = ["events:PutEvents"]
    resources = [aws_cloudwatch_event_bus.this.arn]

    principals {
      type        = "AWS"
      identifiers = var.producer_principal_arns
    }

    condition {
      test     = "StringEquals"
      variable = "events:source"
      values   = var.event_sources
    }

    dynamic "condition" {
      for_each = length(var.detail_types) > 0 ? [1] : []
      content {
        test     = "StringEquals"
        variable = "events:detail-type"
        values   = var.detail_types
      }
    }
  }
}

resource "aws_cloudwatch_event_bus_policy" "this" {
  count = length(var.producer_principal_arns) > 0 ? 1 : 0

  event_bus_name = aws_cloudwatch_event_bus.this.name
  policy         = data.aws_iam_policy_document.bus.json
}

# Fila: aceita só a regra deste módulo (aws:SourceArn) e exige TLS.
data "aws_iam_policy_document" "queue" {
  statement {
    sid       = "AllowRule"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.this.arn]
    }
  }

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.this.arn]

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
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id
  policy    = data.aws_iam_policy_document.queue.json
}

# DLQ: recebe da fila (redrive) e da própria regra quando a entrega falha por 24 h.
data "aws_iam_policy_document" "dlq" {
  statement {
    sid       = "AllowRuleDeadLetter"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.dlq.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.this.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.id
  policy    = data.aws_iam_policy_document.dlq.json
}

resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.this.arn]
  })
}

# Política do consumidor (anexada à role informada, ex.: IRSA do serviço).
data "aws_iam_policy_document" "consumer" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
    ]
    resources = [aws_sqs_queue.this.arn]
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "consumer" {
  count = var.consumer_role_name == null ? 0 : 1

  name   = "${var.name_prefix}-${var.queue_name}-consumer"
  role   = var.consumer_role_name
  policy = data.aws_iam_policy_document.consumer.json
}
