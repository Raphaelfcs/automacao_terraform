# Permission sets do IAM Identity Center (acesso humano federado, sem usuários IAM):
# políticas gerenciadas, inline (JSON), customer managed e permissions boundary, e as
# atribuições grupo -> conta. Roda na conta de gerenciamento ou na administradora delegada.

data "aws_ssoadmin_instances" "this" {}

locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  managed = flatten([for ps, cfg in var.permission_sets : [for arn in cfg.managed_policy_arns : { ps = ps, arn = arn }]])
  customer = flatten([for ps, cfg in var.permission_sets : [for name in cfg.customer_managed_policies : { ps = ps, name = name }]])

  assignments = { for a in var.account_assignments : "${a.permission_set}|${a.group}|${a.account_id}" => a }
  groups      = toset([for a in var.account_assignments : a.group])
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = local.instance_arn
  session_duration = each.value.session_duration
  tags             = var.tags
}

data "aws_identitystore_group" "this" {
  for_each = local.groups

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value
    }
  }
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.assignments

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn
  principal_id       = data.aws_identitystore_group.this[each.value.group].group_id
  principal_type     = "GROUP"
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}
