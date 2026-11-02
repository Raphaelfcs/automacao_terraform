locals {
  event_pattern = jsonencode(merge(
    { source = var.event_sources },
    length(var.detail_types) > 0 ? { "detail-type" = var.detail_types } : {}
  ))
}
