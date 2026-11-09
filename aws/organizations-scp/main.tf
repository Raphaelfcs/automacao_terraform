# Governança da AWS Organizations como código: OUs (dois níveis), SCPs preventivas
# (região permitida, proteção da organização e dos serviços de segurança, root negado,
# criptografia obrigatória, tags na criação), SCP "negar tudo" para contas suspensas e
# Tag Policy de FinOps e, opcionalmente, RCPs de perímetro de dados. Roda na conta de gerenciamento; o Control Tower/AFT cria as contas.
data "aws_organizations_organization" "this" {}

resource "aws_organizations_organizational_unit" "level1" {
  for_each  = local.first_level
  name      = each.key
  parent_id = local.root_id
  tags      = local.tags
}

resource "aws_organizations_organizational_unit" "level2" {
  for_each  = local.second_level
  name      = each.key
  parent_id = aws_organizations_organizational_unit.level1[each.value.parent].id
  tags      = local.tags
}
