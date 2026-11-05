# Registro de OUs no AWS Control Tower pela API: habilita o AWSControlTowerBaseline em cada OU
# (equivalente ao "Register OU" do console). As contas da OU passam a ser governadas pelos
# controles do Control Tower e o Account Factory/AFT pode criar contas nela. As OUs nascem fora
# deste módulo (ex.: organizations-scp); OUs filhas só são registradas depois das OUs pai.

data "aws_region" "current" {}

data "aws_partition" "current" {}

resource "aws_controltower_baseline" "level1" {
  for_each = local.level1

  baseline_identifier = local.baseline_arn
  baseline_version    = var.baseline_version
  target_identifier   = each.value.arn
  tags                = local.tags

  dynamic "parameters" {
    for_each = local.parameters
    content {
      key   = parameters.value.key
      value = parameters.value.value
    }
  }
}

resource "aws_controltower_baseline" "level2" {
  for_each = local.level2

  baseline_identifier = local.baseline_arn
  baseline_version    = var.baseline_version
  target_identifier   = each.value.arn
  tags                = local.tags

  dynamic "parameters" {
    for_each = local.parameters
    content {
      key   = parameters.value.key
      value = parameters.value.value
    }
  }

  # O Control Tower recusa registrar uma OU filha enquanto a OU pai não estiver registrada.
  depends_on = [aws_controltower_baseline.level1]
}
