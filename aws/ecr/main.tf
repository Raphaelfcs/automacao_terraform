# Repositórios ECR — um por serviço containerizado. O pipeline de CI constrói e publica a
# imagem; a IaC só declara onde ela mora, como é cifrada, escaneada e expirada.

resource "aws_ecr_repository" "this" {
  for_each = toset(var.repository_names)

  name                 = var.name_prefix == "" ? each.value : "${var.name_prefix}/${each.value}"
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.kms_key_arn == null ? "AES256" : "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = merge(var.tags, { Name = each.value })
}
