locals {
  alert_targets = merge([
    for alert, cfg in var.metric_alerts : {
      for target in cfg.target_ids :
      "${alert}|${target}" => merge(cfg, {
        alert       = alert
        target_id   = target
        target_name = regex("[^/]+$", target)
      })
    }
  ]...)
}
