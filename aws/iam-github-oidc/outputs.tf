output "deploy_role_arn" {
  description = "Configure como AWS_DEPLOY_ROLE_ARN no GitHub."
  value       = aws_iam_role.deploy.arn
}

output "plan_role_arn" {
  description = "Configure como AWS_PLAN_ROLE_ARN no GitHub."
  value       = aws_iam_role.plan.arn
}

output "oidc_provider_arn" {
  description = "ARN do OIDC provider do GitHub."
  value       = local.oidc_arn
}
