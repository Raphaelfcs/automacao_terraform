# Agenda (EventBridge Scheduler não exige permissão na função; usamos regra clássica para
# manter um único padrão com os gatilhos por evento).
resource "aws_cloudwatch_event_rule" "schedule" {
  count = var.schedule_expression == null ? 0 : 1

  name                = "${var.function_name}-schedule"
  description         = "Agenda de ${var.function_name}"
  schedule_expression = var.schedule_expression
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "schedule" {
  count = var.schedule_expression == null ? 0 : 1

  rule = aws_cloudwatch_event_rule.schedule[0].name
  arn  = aws_lambda_function.this.arn
}

resource "aws_cloudwatch_event_rule" "pattern" {
  for_each = var.event_patterns

  name          = "${var.function_name}-${each.key}"
  description   = "Evento ${each.key} para ${var.function_name}"
  event_pattern = jsonencode(each.value)
  tags          = var.tags
}

resource "aws_cloudwatch_event_target" "pattern" {
  for_each = var.event_patterns

  rule = aws_cloudwatch_event_rule.pattern[each.key].name
  arn  = aws_lambda_function.this.arn
}

resource "aws_lambda_event_source_mapping" "sqs" {
  count = var.sqs_trigger_arn == null ? 0 : 1

  event_source_arn                   = var.sqs_trigger_arn
  function_name                      = aws_lambda_function.this.arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 5
  function_response_types            = ["ReportBatchItemFailures"]
}

resource "aws_lambda_event_source_mapping" "dynamodb" {
  count = var.dynamodb_stream_arn == null ? 0 : 1

  event_source_arn               = var.dynamodb_stream_arn
  function_name                  = aws_lambda_function.this.arn
  starting_position              = "LATEST"
  batch_size                     = 25
  maximum_retry_attempts         = 10
  maximum_record_age_in_seconds  = 86400
  bisect_batch_on_function_error = true
  function_response_types        = ["ReportBatchItemFailures"]

  dynamic "destination_config" {
    for_each = var.stream_failure_destination_arn == null ? [] : [1]
    content {
      on_failure {
        destination_arn = var.stream_failure_destination_arn
      }
    }
  }
}
