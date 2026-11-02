# VPC Flow Logs para o CloudWatch Logs (auditoria e troubleshooting de rede).
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.flow_logs_retention_days > 0 ? 1 : 0

  name              = "/aws/vpc/${var.name_prefix}/flow-logs"
  retention_in_days = var.flow_logs_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.tags
}

resource "aws_flow_log" "this" {
  count = var.flow_logs_retention_days > 0 ? 1 : 0

  vpc_id                   = aws_vpc.this.id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.flow_logs[0].arn
  iam_role_arn             = aws_iam_role.flow_logs[0].arn
  max_aggregation_interval = 60

  tags = merge(var.tags, { Name = "${var.name_prefix}-flow-logs" })
}
