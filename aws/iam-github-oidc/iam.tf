resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # A AWS valida o GitHub pela CA raiz; os thumbprints são mantidos por compatibilidade.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  tags            = var.tags
}

data "aws_iam_policy_document" "trust_deploy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.deploy_subjects
    }
  }
}

data "aws_iam_policy_document" "trust_plan" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.plan_subjects
    }
  }
}

resource "aws_iam_role" "deploy" {
  name                 = "github-${var.github_repo}-deploy"
  assume_role_policy   = data.aws_iam_policy_document.trust_deploy.json
  max_session_duration = 3600
  permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "deploy" {
  for_each = toset(var.deploy_policy_arns)

  role       = aws_iam_role.deploy.name
  policy_arn = each.value
}

# PowerUser não gerencia IAM: libera só roles com o prefixo dos projetos.
resource "aws_iam_role_policy" "deploy_iam" {
  count = var.managed_role_prefix == null ? 0 : 1

  name = "iam-dos-projetos"
  role = aws_iam_role.deploy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:UpdateRole", "iam:TagRole", "iam:UntagRole",
        "iam:PassRole", "iam:PutRolePolicy", "iam:GetRolePolicy", "iam:DeleteRolePolicy", "iam:AttachRolePolicy",
        "iam:DetachRolePolicy", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole", "iam:UpdateAssumeRolePolicy",
      ]
      Resource = ["arn:aws:iam::${local.account_id}:role/${var.managed_role_prefix}*"]
    }]
  })
}

resource "aws_iam_role" "plan" {
  name                 = "github-${var.github_repo}-plan"
  assume_role_policy   = data.aws_iam_policy_document.trust_plan.json
  max_session_duration = 3600
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "plan" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# As duas roles leem/gravam o estado (o plan precisa criar o lock file .tflock).
data "aws_iam_policy_document" "state_access" {
  count = var.state_bucket_arn == null ? 0 : 1

  statement {
    actions   = ["s3:ListBucket"]
    resources = [var.state_bucket_arn]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.state_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "state" {
  for_each = var.state_bucket_arn == null ? {} : { plan = aws_iam_role.plan.id, deploy = aws_iam_role.deploy.id }

  name   = "estado-terraform"
  role   = each.value
  policy = data.aws_iam_policy_document.state_access[0].json
}
