resource "aws_organizations_policy" "scp" {
  for_each    = local.scps
  name        = each.key
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({ Version = "2012-10-17", Statement = each.value.statements })
  tags        = local.tags
}

resource "aws_organizations_policy_attachment" "scp" {
  for_each = {
    for pair in setproduct(keys(local.scps), keys(local.attach_ids)) : "${pair[0]}|${pair[1]}" => { policy = pair[0], target = local.attach_ids[pair[1]] }
  }
  policy_id = aws_organizations_policy.scp[each.value.policy].id
  target_id = each.value.target
}

# contas suspensas: nada é permitido
resource "aws_organizations_policy" "suspended" {
  count       = contains(keys(var.organizational_units), "Suspended") ? 1 : 0
  name        = "negar-tudo-suspensas"
  description = "Contas em encerramento: bloqueia qualquer ação"
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Sid = "NegarTudo", Effect = "Deny", Action = "*", Resource = "*" }]
  })
  tags = local.tags
}

resource "aws_organizations_policy_attachment" "suspended" {
  count     = length(aws_organizations_policy.suspended)
  policy_id = aws_organizations_policy.suspended[0].id
  target_id = local.ou_ids["Suspended"]
}

resource "aws_organizations_policy" "tags" {
  name        = "tags-obrigatorias"
  description = "Padroniza as chaves de tag de custo e responsabilidade (FinOps)"
  type        = "TAG_POLICY"
  content     = jsonencode(local.tag_policy)
  tags        = local.tags
}

resource "aws_organizations_policy_attachment" "tags" {
  policy_id = aws_organizations_policy.tags.id
  target_id = local.root_id
}
