locals {
  tags   = merge({ Gerenciado = "terraform", Camada = "finops" }, var.tags)
  freeze = length(var.freeze_target_ids) > 0
}
