# Role que o AWS Budgets assume para anexar a SCP de congelamento (somente essa política).

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "budgets_action" {
  count = local.freeze ? 1 : 0

  name = "${var.name}-budgets-action"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "budgets.${data.aws_partition.current.dns_suffix}" }
      Action    = "sts:AssumeRole"
      Condition = { StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id } }
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy" "budgets_action" {
  count = local.freeze ? 1 : 0

  name = "anexar-scp-congelamento"
  role = aws_iam_role.budgets_action[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["organizations:AttachPolicy", "organizations:DetachPolicy"]
        Resource = "*"
        Condition = {
          StringEquals = { "organizations:PolicyType" = "SERVICE_CONTROL_POLICY" }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["organizations:DescribePolicy", "organizations:ListTargetsForPolicy", "organizations:DescribeOrganization"]
        Resource = "*"
      },
    ]
  })
}
