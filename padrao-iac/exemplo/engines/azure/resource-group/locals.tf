locals {
  nome = "rg-${var.projeto}-${var.ambiente}"
  tags = merge(var.tags, {
    projeto    = var.projeto
    ambiente   = var.ambiente
    gerenciado = "terraform"
    engine     = "azure/resource-group"
  })
}
