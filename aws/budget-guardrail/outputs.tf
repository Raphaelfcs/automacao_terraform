output "budget_name" {
  description = "Nome do budget."
  value       = aws_budgets_budget.this.name
}

output "freeze_policy_id" {
  description = "ID da SCP de congelamento (null sem ação automática). Para descongelar: desanexe-a."
  value       = try(aws_organizations_policy.freeze[0].id, null)
}
