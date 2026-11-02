# Tópicos SNS cifrados com KMS, com assinaturas declarativas (lambda, sqs, email, https)
# e política de tópico restrita à conta e a serviços publicadores informados.

resource "aws_sns_topic" "this" {
  for_each = toset(var.topic_names)

  name                        = var.fifo ? "${var.name_prefix}${each.value}.fifo" : "${var.name_prefix}${each.value}"
  fifo_topic                  = var.fifo
  content_based_deduplication = var.fifo
  kms_master_key_id           = var.kms_key_arn

  tags = merge(var.tags, { Name = each.value })
}

resource "aws_sns_topic_subscription" "this" {
  for_each = { for s in local.subscriptions : "${s.topic}|${s.protocol}|${s.endpoint}" => s }

  topic_arn            = aws_sns_topic.this[each.value.topic].arn
  protocol             = each.value.protocol
  endpoint             = each.value.endpoint
  raw_message_delivery = contains(["sqs", "https", "firehose"], each.value.protocol) ? each.value.raw : null
  filter_policy        = each.value.filter_policy
}
