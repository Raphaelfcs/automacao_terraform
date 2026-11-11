locals {
  managed = [for i, n in var.managed_rule_groups : { name = n, priority = 10 + i }]
}
