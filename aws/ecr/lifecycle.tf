# Retenção de imagens: expira imagens sem tag rapidamente e mantém só as N mais recentes
# com os prefixos de release informados. Reduz custo de armazenamento (pilar Custo).
resource "aws_ecr_lifecycle_policy" "this" {
  for_each = aws_ecr_repository.this

  repository = each.value.name

  policy = jsonencode({
    rules = concat(
      [{
        rulePriority = 1
        description  = "Expirar imagens sem tag após ${var.untagged_expiration_days} dias"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_expiration_days
        }
        action = { type = "expire" }
      }],
      # Uma única regra 2 com seleção montada por merge: sem prefixos, conta qualquer imagem;
      # com prefixos, só as de release. (Ramos de um condicional precisam ter o mesmo tipo.)
      [{
        rulePriority = 2
        description = (length(var.release_tag_prefixes) == 0
          ? "Manter apenas as ${var.max_image_count} imagens mais recentes"
        : "Manter as ${var.max_image_count} últimas imagens de release")
        selection = merge(
          {
            tagStatus   = length(var.release_tag_prefixes) == 0 ? "any" : "tagged"
            countType   = "imageCountMoreThan"
            countNumber = var.max_image_count
          },
          { for k, v in { tagPrefixList = var.release_tag_prefixes } : k => v if length(var.release_tag_prefixes) > 0 }
        )
        action = { type = "expire" }
      }]
    )
  })
}
