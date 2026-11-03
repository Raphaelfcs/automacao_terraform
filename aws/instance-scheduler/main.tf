# Agendador FinOps de EC2/RDS por tag: EventBridge Scheduler (cron com fuso horário)
# invoca a Lambda com {"action": "start"|"stop"}. Redesenho dos antigos scripts
# Start-EC2/Stop-EC2/RdsStopTime. Para node groups EKS use o módulo autoscaling-schedule.

module "function" {
  source = "../lambda-function"

  function_name = "${var.name_prefix}-instance-scheduler"
  description   = "Liga/desliga EC2 e RDS por tag"
  source_dir    = "${path.module}/src"
  timeout       = 120
  kms_key_arn   = var.kms_key_arn

  environment = {
    SCHEDULE_TAG   = var.schedule_tag
    SCHEDULE_VALUE = var.schedule_value
    DRY_RUN        = tostring(var.dry_run)
  }

  policy_json = data.aws_iam_policy_document.function.json

  attach_policy_json = true
  tags               = var.tags
}

resource "aws_scheduler_schedule" "this" {
  for_each = { start = var.start_cron, stop = var.stop_cron }

  name                         = "${var.name_prefix}-scheduler-${each.key}"
  schedule_expression          = each.value
  schedule_expression_timezone = var.timezone

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = module.function.function_arn
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ action = each.key })

    retry_policy {
      maximum_retry_attempts = 2
    }
  }
}
