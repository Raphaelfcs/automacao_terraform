locals {
  subscriptions = flatten([
    for topic, subs in var.subscriptions : [
      for s in subs : {
        topic         = topic
        protocol      = s.protocol
        endpoint      = s.endpoint
        raw           = s.raw_message_delivery
        filter_policy = s.filter_policy == null ? null : jsonencode(s.filter_policy)
      }
    ]
  ])

  lambda_endpoints = { for s in local.subscriptions : "${s.topic}|${s.endpoint}" => s if s.protocol == "lambda" }
}
