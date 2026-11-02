# Chave KMS gerenciada pelo cliente (CMK) para criptografia em repouso de vários serviços
# da mesma conta (RDS, MSK, ElastiCache, EBS, S3, segredos do EKS, CloudWatch Logs).
# Rotação automática sempre ligada (pilar Segurança do Well-Architected).

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_kms_key" "this" {
  description             = coalesce(var.description, "${var.name_prefix} - criptografia em repouso")
  enable_key_rotation     = true
  rotation_period_in_days = var.rotation_period_in_days
  deletion_window_in_days = var.deletion_window_in_days
  multi_region            = var.multi_region
  policy                  = data.aws_iam_policy_document.key.json

  tags = merge(var.tags, { Name = "${var.name_prefix}-kms" })
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name_prefix}"
  target_key_id = aws_kms_key.this.key_id
}
