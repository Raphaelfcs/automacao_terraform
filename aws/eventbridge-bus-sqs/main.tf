# Integração orientada a eventos entre contas: um produtor (outra conta AWS) publica num
# barramento EventBridge dedicado; uma regra entrega numa fila SQS cifrada com DLQ; o
# archive permite replay sem depender do produtor. Alarmes cobrem consumidor parado,
# mensagens antigas, DLQ e falha de entrega da regra.

resource "aws_cloudwatch_event_bus" "this" {
  name = "${var.name_prefix}-${var.bus_name}"
  tags = var.tags
}

resource "aws_cloudwatch_event_archive" "this" {
  count = var.archive_retention_days > 0 ? 1 : 0

  name             = "${var.name_prefix}-${var.bus_name}-archive"
  event_source_arn = aws_cloudwatch_event_bus.this.arn
  retention_days   = var.archive_retention_days
  event_pattern    = local.event_pattern
}

# A DLQ guarda o máximo do SQS (14 dias): a retenção conta a partir do envio original.
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name_prefix}-${var.queue_name}-dlq"
  message_retention_seconds = 1209600
  kms_master_key_id         = var.kms_key_arn
  tags                      = var.tags
}

resource "aws_sqs_queue" "this" {
  name                       = "${var.name_prefix}-${var.queue_name}"
  message_retention_seconds  = var.queue_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  receive_wait_time_seconds  = 20
  kms_master_key_id          = var.kms_key_arn

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "this" {
  name           = "${var.name_prefix}-${var.queue_name}"
  description    = "Eventos ${join(",", var.event_sources)} para a fila ${var.queue_name}"
  event_bus_name = aws_cloudwatch_event_bus.this.name
  event_pattern  = local.event_pattern
  tags           = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  rule           = aws_cloudwatch_event_rule.this.name
  event_bus_name = aws_cloudwatch_event_bus.this.name
  target_id      = "sqs-${var.queue_name}"
  arn            = aws_sqs_queue.this.arn

  retry_policy {
    maximum_event_age_in_seconds = 86400
    maximum_retry_attempts       = 185
  }

  dead_letter_config {
    arn = aws_sqs_queue.dlq.arn
  }
}
