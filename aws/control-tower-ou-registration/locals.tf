locals {
  tags = merge({ Gerenciado = "terraform", Camada = "landing-zone" }, var.tags)

  # AWSControlTowerBaseline: identificador fixo publicado pela AWS, varia só a região/partição.
  baseline_arn = coalesce(
    var.baseline_arn,
    "arn:${data.aws_partition.current.partition}:controltower:${data.aws_region.current.region}::baseline/17BSJV3IGJ2QSGA2",
  )

  parameters = var.identity_center_enabled_baseline_arn == null ? [] : [{
    key   = "IdentityCenterEnabledBaselineArn"
    value = var.identity_center_enabled_baseline_arn
  }]

  level1 = { for k, v in var.organizational_units : k => v if v.parent == null }
  level2 = { for k, v in var.organizational_units : k => v if v.parent != null }
}
