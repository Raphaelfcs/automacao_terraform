locals {
  waf_rules = [for i, id in var.waf_rule_ids : { id = id, priority = 1000 + i }]

  security_headers = [
    "Strict-Transport-Security: max-age=63072000; includeSubDomains; preload",
    "X-Content-Type-Options: nosniff",
    "X-Frame-Options: DENY",
    "Referrer-Policy: no-referrer",
    "Permissions-Policy: camera=(), microphone=(), geolocation=()",
    "Content-Security-Policy: ${var.content_security_policy}",
  ]
}
