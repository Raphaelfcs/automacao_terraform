# Conta governada criada pelo Account Factory do AWS Control Tower (produto do Service Catalog):
# a conta já nasce matriculada na OU registrada, com o usuário SSO dono e os controles da OU.
# Indicado para contas que precisam existir ANTES do AFT (ex.: a conta de gerenciamento do AFT);
# depois disso, novas contas devem vir por pull request no repositório de account requests do AFT.

resource "aws_servicecatalog_provisioned_product" "account" {
  name                       = coalesce(var.provisioned_product_name, "conta-${var.account_name}")
  product_name               = var.product_name
  provisioning_artifact_name = var.provisioning_artifact_name

  dynamic "provisioning_parameters" {
    for_each = local.parameters
    content {
      key   = provisioning_parameters.key
      value = provisioning_parameters.value
    }
  }

  tags = local.tags

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }

  lifecycle {
    # Renomear OU ou usuário fora daqui não deve disparar update/recriação da conta.
    ignore_changes = [provisioning_parameters]
  }
}
