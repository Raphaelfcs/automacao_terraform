# Grupos (e, opcionalmente, usuários) do IAM Identity Center no diretório interno: a base do
# acesso humano federado, sem usuários IAM. Os permission sets e as atribuições grupo -> conta
# ficam no módulo identity-center-permission-set, que referencia estes grupos pelo nome.

data "aws_ssoadmin_instances" "this" {}

resource "aws_identitystore_group" "this" {
  for_each = var.groups

  identity_store_id = local.identity_store_id
  display_name      = each.key
  description       = each.value
}

resource "aws_identitystore_user" "this" {
  for_each = var.users

  identity_store_id = local.identity_store_id
  user_name         = each.key
  display_name      = "${each.value.given_name} ${each.value.family_name}"

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value   = coalesce(each.value.email, each.key)
    primary = true
  }
}

resource "aws_identitystore_group_membership" "this" {
  for_each = local.memberships

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.this[each.value.group].group_id
  member_id         = aws_identitystore_user.this[each.value.user].user_id
}
