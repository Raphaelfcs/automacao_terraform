# Filas SQS (standard ou FIFO) cifradas, com DLQ opcional por fila, long polling e
# política de redrive restrita à fila de origem.

resource "aws_sqs_queue" "dlq" {
  for_each = var.enable_dead_letter ? toset(var.queues) : toset([])

  name                      = "${var.name_prefix}${each.key}-dlq${var.fifo ? ".fifo" : ""}"
  fifo_queue                = var.fifo
  message_retention_seconds = 1209600
  kms_master_key_id         = var.kms_key_arn
  sqs_managed_sse_enabled   = var.kms_key_arn == null ? true : null

  tags = var.tags
}

resource "aws_sqs_queue" "this" {
  for_each = toset(var.queues)

  name                        = "${var.name_prefix}${each.key}${var.fifo ? ".fifo" : ""}"
  fifo_queue                  = var.fifo
  content_based_deduplication = var.fifo
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  max_message_size            = var.max_message_size
  delay_seconds               = var.delay_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  kms_master_key_id           = var.kms_key_arn
  sqs_managed_sse_enabled     = var.kms_key_arn == null ? true : null

  redrive_policy = var.enable_dead_letter ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = var.tags
}
