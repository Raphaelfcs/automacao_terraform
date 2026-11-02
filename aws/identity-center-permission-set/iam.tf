resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = { for m in local.managed : "${m.ps}|${m.arn}" => m }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps].arn
  managed_policy_arn = each.value.arn
}

# Inline policy: as antigas políticas JSON de time (rede somente leitura, deploy etc.)
# entram aqui, versionadas, em vez de editadas no console.
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = { for k, v in var.permission_sets : k => v if v.inline_policy != null }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = each.value.inline_policy
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  for_each = { for c in local.customer : "${c.ps}|${c.name}" => c }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps].arn

  customer_managed_policy_reference {
    name = each.value.name
    path = "/"
  }
}

resource "aws_ssoadmin_permissions_boundary_attachment" "this" {
  for_each = { for k, v in var.permission_sets : k => v if v.boundary_policy_name != null }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn

  permissions_boundary {
    customer_managed_policy_reference {
      name = each.value.boundary_policy_name
      path = "/"
    }
  }
}
