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
      length(var.release_tag_prefixes) == 0 ? [{
        rulePriority = 2
        description  = "Manter apenas as ${var.max_image_count} imagens mais recentes"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = { type = "expire" }
        }] : [{
        rulePriority = 2
        description  = "Manter as ${var.max_image_count} últimas imagens de release"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = var.release_tag_prefixes
          countType     = "imageCountMoreThan"
          countNumber   = var.max_image_count
        }
        action = { type = "expire" }
      }]
    )
  })
}
