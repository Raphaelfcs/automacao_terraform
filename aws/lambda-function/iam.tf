data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = "${var.function_name}-role"
  assume_role_policy   = data.aws_iam_policy_document.assume.json
  permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.this.name
  policy_arn = var.vpc == null ? "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" : "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "xray" {
  count = var.tracing ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Permissões específicas da função (JSON de policy document), escopadas por quem chama.
resource "aws_iam_role_policy" "inline" {
  count = var.attach_policy_json ? 1 : 0

  name   = "${var.function_name}-permissoes"
  role   = aws_iam_role.this.id
  policy = var.policy_json

  lifecycle {
    precondition {
      condition     = var.policy_json != null
      error_message = "attach_policy_json = true exige policy_json."
    }
  }
}

data "aws_iam_policy_document" "sqs_trigger" {
  count = var.sqs_trigger_arn == null ? 0 : 1

  statement {
    actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ChangeMessageVisibility"]
    resources = [var.sqs_trigger_arn]
  }
}

resource "aws_iam_role_policy" "sqs_trigger" {
  count = var.sqs_trigger_arn == null ? 0 : 1

  name   = "${var.function_name}-sqs"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.sqs_trigger[0].json
}

resource "aws_lambda_permission" "schedule" {
  count = var.schedule_expression == null ? 0 : 1

  statement_id  = "AllowEventBridgeSchedule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[0].arn
}

resource "aws_lambda_permission" "pattern" {
  for_each = var.event_patterns

  statement_id  = "AllowEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pattern[each.key].arn
}
