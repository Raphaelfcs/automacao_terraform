# Política EXPLÍCITA da chave. A política padrão concede `kms:*` à conta e delega o resto
# ao IAM: isso serve para roles e usuários da conta, mas NÃO para um serviço da AWS agindo
# em nome próprio (ex.: o CloudWatch Logs cifra log groups como `logs.<regiao>.amazonaws.com`).
# Sem a declaração abaixo, a criação de log groups cifrados (EKS, MSK, Lambda) falha com
# "The specified KMS key does not exist or is not allowed to be used".
data "aws_iam_policy_document" "key" {
  # A conta administra a chave e o IAM decide o resto (mesma linha da política padrão).
  statement {
    sid       = "EnableIAMUserPermissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # Administradores explícitos da chave (opcional), separados de quem só usa a chave.
  dynamic "statement" {
    for_each = length(var.key_administrator_arns) == 0 ? [] : [var.key_administrator_arns]
    content {
      sid = "KeyAdministrators"
      actions = [
        "kms:Create*", "kms:Describe*", "kms:Enable*", "kms:List*", "kms:Put*", "kms:Update*",
        "kms:Revoke*", "kms:Disable*", "kms:Get*", "kms:Delete*", "kms:TagResource",
        "kms:UntagResource", "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion",
      ]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = statement.value
      }
    }
  }

  # CloudWatch Logs, restrito aos log groups DESTA conta e região pelo contexto de cifra.
  dynamic "statement" {
    for_each = var.allow_cloudwatch_logs ? [1] : []
    content {
      sid = "AllowCloudWatchLogs"
      actions = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*",
      ]
      resources = ["*"]

      principals {
        type        = "Service"
        identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
      }

      condition {
        test     = "ArnLike"
        variable = "kms:EncryptionContext:aws:logs:arn"
        values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:*"]
      }
    }
  }

  # Regras do EventBridge que entregam em filas SQS / tópicos SNS cifrados com esta chave.
  # Restrito às regras informadas (aws:SourceArn) e à própria conta (aws:SourceAccount).
  dynamic "statement" {
    for_each = length(var.event_rule_arns) == 0 ? [] : [var.event_rule_arns]
    content {
      sid       = "AllowEventBridgeRulesToEncryptedQueues"
      actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
      resources = ["*"]

      principals {
        type        = "Service"
        identifiers = ["events.amazonaws.com"]
      }

      condition {
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = statement.value
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }

  # Outros serviços que precisam usar a chave em nome próprio (ex.: sns.amazonaws.com).
  dynamic "statement" {
    for_each = length(var.service_principals) == 0 ? [] : [var.service_principals]
    content {
      sid       = "AllowAwsServices"
      actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
      resources = ["*"]

      principals {
        type        = "Service"
        identifiers = statement.value
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }
}
