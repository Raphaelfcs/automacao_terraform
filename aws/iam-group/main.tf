# Grupo IAM com políticas gerenciadas e customizadas e membros declarados.
# Para pessoas, prefira IAM Identity Center (módulo identity-center-permission-set);
# use grupos IAM para contas legadas, break-glass ou integrações que exigem usuário IAM.

resource "aws_iam_group" "this" {
  name = var.name
  path = var.path
}

resource "aws_iam_group_membership" "this" {
  count = length(var.members) > 0 ? 1 : 0

  name  = "${var.name}-membros"
  group = aws_iam_group.this.name
  users = var.members
}
