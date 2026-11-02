data "aws_iam_policy_document" "function" {
  statement {
    sid       = "ReadIam"
    actions   = ["iam:ListUsers", "iam:GetLoginProfile", "iam:ListMFADevices"]
    resources = ["*"]
  }

  statement {
    sid       = "Notify"
    actions   = ["sns:Publish"]
    resources = [var.alert_topic_arn]
  }
}
