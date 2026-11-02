data "aws_caller_identity" "current" {}

# Política do tópico: a própria conta publica/assina; serviços informados podem publicar
# (ex.: events.amazonaws.com, cloudwatch.amazonaws.com) restritos a esta conta.
data "aws_iam_policy_document" "topic" {
  for_each = aws_sns_topic.this

  statement {
    sid       = "OwnerAccount"
    actions   = ["sns:Publish", "sns:Subscribe", "sns:GetTopicAttributes", "sns:SetTopicAttributes", "sns:ListSubscriptionsByTopic"]
    resources = [each.value.arn]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  dynamic "statement" {
    for_each = length(var.publisher_services) > 0 ? [1] : []
    content {
      sid       = "AwsServicesPublish"
      actions   = ["sns:Publish"]
      resources = [each.value.arn]
      principals {
        type        = "Service"
        identifiers = var.publisher_services
      }
      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }
}

resource "aws_sns_topic_policy" "this" {
  for_each = aws_sns_topic.this

  arn    = each.value.arn
  policy = data.aws_iam_policy_document.topic[each.key].json
}

# Permissão para o SNS invocar as Lambdas assinantes.
resource "aws_lambda_permission" "sns" {
  for_each = local.lambda_endpoints

  statement_id  = "AllowSNS-${replace(each.value.topic, "/[^A-Za-z0-9_-]/", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.endpoint
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.this[each.value.topic].arn
}
