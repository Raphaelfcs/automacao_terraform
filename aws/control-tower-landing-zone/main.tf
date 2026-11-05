# Landing zone do AWS Control Tower (versão 4.0) como código, a partir da conta de gerenciamento:
# OU de segurança, contas compartilhadas Log Archive e Audit, as quatro service roles exigidas pela
# API e o manifesto com cada integração ligada ou desligada de forma explícita (Identity Center,
# AWS Config, logs centralizados, security roles e Backup). Pré-requisito: AWS Organizations com
# todas as features habilitadas. As OUs de workload e o registro delas ficam em outros módulos.

data "aws_organizations_organization" "this" {}

data "aws_region" "current" {}

# OU onde ficam as contas de serviço do Control Tower: precisa estar logo abaixo da raiz.
resource "aws_organizations_organizational_unit" "security" {
  count     = var.existing_security_ou_id == null ? 1 : 0
  name      = var.security_ou_name
  parent_id = local.root_id
  tags      = local.tags
}

# Log Archive e Audit: criadas aqui quando não se informa o ID de uma conta existente.
resource "aws_organizations_account" "shared" {
  for_each = local.accounts_to_create

  name                       = each.value.name
  email                      = each.value.email
  parent_id                  = local.security_ou_id
  iam_user_access_to_billing = "DENY"
  close_on_deletion          = false
  tags                       = merge(local.tags, { Funcao = each.key })

  lifecycle {
    # O e-mail e o nome viram identidade da conta; mudar fora daqui não deve recriá-la.
    ignore_changes = [role_name, iam_user_access_to_billing, name, email]
  }
}

resource "aws_controltower_landing_zone" "this" {
  manifest_json = jsonencode(local.manifest)
  version       = var.landing_zone_version
  tags          = local.tags

  lifecycle {
    precondition {
      condition     = var.enable_config || (!var.enable_identity_center && !var.enable_security_roles && var.backup == null)
      error_message = "Com AWS Config desligado, Identity Center, security roles e Backup também precisam estar desligados (regra do manifesto 4.0)."
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.admin,
    aws_iam_role_policy.admin,
    aws_iam_role_policy.cloudtrail,
    aws_iam_role_policy.stackset,
    aws_iam_role_policy_attachment.config_aggregator,
  ]

  timeouts {
    create = "120m"
    update = "120m"
    delete = "120m"
  }
}
