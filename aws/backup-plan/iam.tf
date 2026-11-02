data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name               = "${var.name_prefix}-backup"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore",
  ])

  role       = aws_iam_role.backup.name
  policy_arn = each.value
}

# Impede apagar recovery points fora do ciclo de vida (defesa contra exclusão maliciosa).
data "aws_iam_policy_document" "vault" {
  statement {
    sid       = "DenyDeleteRecoveryPoints"
    effect    = "Deny"
    actions   = ["backup:DeleteRecoveryPoint", "backup:UpdateRecoveryPointLifecycle", "backup:PutBackupVaultAccessPolicy"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = var.vault_admin_role_arns
    }
  }
}

resource "aws_backup_vault_policy" "this" {
  count = length(var.vault_admin_role_arns) > 0 ? 1 : 0

  backup_vault_name = aws_backup_vault.this.name
  policy            = data.aws_iam_policy_document.vault.json
}
