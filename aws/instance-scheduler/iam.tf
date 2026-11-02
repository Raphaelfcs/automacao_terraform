data "aws_iam_policy_document" "function" {
  statement {
    sid       = "Describe"
    actions   = ["ec2:DescribeInstances", "rds:DescribeDBInstances", "rds:ListTagsForResource"]
    resources = ["*"]
  }

  # Start/Stop apenas em recursos com a tag de agenda.
  statement {
    sid       = "StartStopTaggedEc2"
    actions   = ["ec2:StartInstances", "ec2:StopInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.schedule_tag}"
      values   = [var.schedule_value]
    }
  }

  statement {
    sid       = "StartStopTaggedRds"
    actions   = ["rds:StartDBInstance", "rds:StopDBInstance"]
    resources = ["arn:aws:rds:*:*:db:*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/${var.schedule_tag}"
      values   = [var.schedule_value]
    }
  }

  # Volumes cifrados com CMK exigem grant para iniciar a instância.
  dynamic "statement" {
    for_each = length(var.ebs_kms_key_arns) > 0 ? [1] : []
    content {
      sid       = "EbsKmsGrant"
      actions   = ["kms:CreateGrant"]
      resources = var.ebs_kms_key_arns
      condition {
        test     = "Bool"
        variable = "kms:GrantIsForAWSResource"
        values   = ["true"]
      }
    }
  }
}

data "aws_iam_policy_document" "scheduler_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "scheduler" {
  name               = "${var.name_prefix}-scheduler-invoke"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "scheduler" {
  name = "invoke"
  role = aws_iam_role.scheduler.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "lambda:InvokeFunction", Resource = module.function.function_arn }]
  })
}
