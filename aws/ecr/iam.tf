# Acesso entre contas: as contas de workload (dev/hml/prd) só PUXAM imagens; quem publica
# é a role do pipeline na conta de ferramentas. Substitui o antigo padrão "ecr:*" para "*".
data "aws_iam_policy_document" "repository" {
  count = length(var.pull_principal_arns) + length(var.push_principal_arns) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = length(var.pull_principal_arns) > 0 ? [1] : []
    content {
      sid    = "CrossAccountPull"
      effect = "Allow"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
      ]
      principals {
        type        = "AWS"
        identifiers = var.pull_principal_arns
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.push_principal_arns) > 0 ? [1] : []
    content {
      sid    = "PipelinePush"
      effect = "Allow"
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
      ]
      principals {
        type        = "AWS"
        identifiers = var.push_principal_arns
      }
    }
  }
}

resource "aws_ecr_repository_policy" "this" {
  for_each = length(data.aws_iam_policy_document.repository) > 0 ? aws_ecr_repository.this : {}

  repository = each.value.name
  policy     = data.aws_iam_policy_document.repository[0].json
}
