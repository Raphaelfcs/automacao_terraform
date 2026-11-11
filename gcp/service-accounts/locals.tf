locals {
  pares = flatten([for k, a in var.accounts : [for p in a.project_roles : { conta = k, papel = p }]])
}
