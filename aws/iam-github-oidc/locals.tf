locals {
  repo       = "${var.github_org}/${var.github_repo}"
  account_id = data.aws_caller_identity.current.account_id
  oidc_arn   = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"

  # Deploy: só jobs com environment aprovado.
  deploy_subjects = [for e in var.allowed_environments : "repo:${local.repo}:environment:${e}"]
  # Plan: PRs (opcional) e a branch principal.
  plan_subjects = concat(
    var.allow_pull_requests ? ["repo:${local.repo}:pull_request"] : [],
    ["repo:${local.repo}:ref:refs/heads/${var.default_branch}"],
  )
}
