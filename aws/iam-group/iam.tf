resource "aws_iam_policy" "custom" {
  for_each = var.custom_policies

  name        = "${var.name}-${each.key}"
  path        = var.path
  description = "Politica ${each.key} do grupo ${var.name}"
  policy      = each.value
}

resource "aws_iam_group_policy_attachment" "custom" {
  for_each = aws_iam_policy.custom

  group      = aws_iam_group.this.name
  policy_arn = each.value.arn
}

resource "aws_iam_group_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  group      = aws_iam_group.this.name
  policy_arn = each.value
}

# MFA obrigatório: nega tudo (exceto gerenciar o próprio MFA) sem sessão autenticada com MFA.
data "aws_iam_policy_document" "require_mfa" {
  statement {
    sid    = "DenyAllExceptMfaSetupWithoutMfa"
    effect = "Deny"
    not_actions = [
      "iam:CreateVirtualMFADevice", "iam:EnableMFADevice", "iam:GetUser", "iam:ListMFADevices",
      "iam:ListVirtualMFADevices", "iam:ResyncMFADevice", "sts:GetSessionToken", "iam:ChangePassword",
    ]
    resources = ["*"]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

resource "aws_iam_group_policy" "require_mfa" {
  count = var.require_mfa ? 1 : 0

  name   = "exigir-mfa"
  group  = aws_iam_group.this.name
  policy = data.aws_iam_policy_document.require_mfa.json
}
