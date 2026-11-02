data "aws_iam_policy_document" "function" {
  statement {
    sid       = "TagAndInspect"
    actions   = ["ec2:CreateTags", "ec2:DescribeInstances", "rds:AddTagsToResource", "rds:ListTagsForResource"]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.enforce ? [1] : []
    content {
      sid       = "StopNonCompliant"
      actions   = ["ec2:StopInstances"]
      resources = ["*"]
    }
  }

  statement {
    sid       = "Notify"
    actions   = ["sns:Publish"]
    resources = [var.alert_topic_arn]
  }
}
