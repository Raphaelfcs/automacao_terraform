# Confiança IRSA: só o ServiceAccount exato assume a role. Sem a condição sub, qualquer
# pod do cluster assumiria o papel — menor privilégio vira decoração.
data "aws_iam_policy_document" "collector_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.collector_namespace}:${var.collector_service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "collector" {
  name               = "${var.role_name_prefix}-log-collector"
  description        = "IRSA do coletor de logs - escreve em ${var.log_group_name} e NAO cria log group"
  assume_role_policy = data.aws_iam_policy_document.collector_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "collector" {
  statement {
    sid = "WriteApplicationLogGroup"
    # logs:CreateLogGroup ausente de propósito (ver main.tf).
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
    resources = [aws_cloudwatch_log_group.application.arn, "${aws_cloudwatch_log_group.application.arn}:*"]
  }

  # Grupo cifrado: sem GenerateDataKey o PutLogEvents falha com AccessDenied na primeira linha.
  dynamic "statement" {
    for_each = var.kms_key_arn == null ? [] : [var.kms_key_arn]
    content {
      sid       = "EncryptWithKey"
      actions   = ["kms:GenerateDataKey"]
      resources = [statement.value]
    }
  }
}

resource "aws_iam_policy" "collector" {
  name        = "${var.role_name_prefix}-log-collector"
  description = "Escrita no log de aplicacao, sem criacao de log group."
  policy      = data.aws_iam_policy_document.collector.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "collector" {
  role       = aws_iam_role.collector.name
  policy_arn = aws_iam_policy.collector.arn
}

# Leitura (NOC, backoffice). Declarada junto do grupo porque o escopo é o ARN do grupo.
data "aws_iam_policy_document" "reader" {
  statement {
    sid       = "ReadApplicationLogs"
    actions   = ["logs:FilterLogEvents", "logs:GetLogEvents"]
    resources = ["${aws_cloudwatch_log_group.application.arn}:*"]
  }

  # logs:DescribeLogGroups EXIGE Resource "*" (é uma listagem; com "log-group:*" o
  # iam simulate-custom-policy retorna implicitDeny). Estreite na chamada com
  # logGroupNamePrefix. É metadado (nome, retenção), não conteúdo.
  statement {
    sid       = "ReadRetentionMetadata"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "reader" {
  name        = "${var.role_name_prefix}-log-reader"
  description = "Leitura do log de aplicacao."
  policy      = data.aws_iam_policy_document.reader.json
  tags        = var.tags
}
