output "enabled_baseline_arns" {
  description = "ARN do baseline habilitado por OU (use em reset-enabled-baseline para re-registrar)."
  value = merge(
    { for k, b in aws_controltower_baseline.level1 : k => b.arn },
    { for k, b in aws_controltower_baseline.level2 : k => b.arn },
  )
}

output "registered_ous" {
  description = "Nomes das OUs registradas no Control Tower."
  value       = sort(concat(keys(local.level1), keys(local.level2)))
}
