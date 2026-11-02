resource "google_compute_global_address" "lb" {
  project = var.project_id
  name    = var.ip_name
}

resource "google_compute_security_policy" "armor" {
  project     = var.project_id
  name        = var.policy_name
  description = "WAF, limite de requisições e geografia para a API do laboratório"
  type        = "CLOUD_ARMOR"

  advanced_options_config {
    log_level = "VERBOSE" # registra qual assinatura WAF casou (útil para análise)
  }

  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }

  # Geografia (opcional). Atenção: o Cloud Shell sai pelos EUA.
  dynamic "rule" {
    for_each = var.allowed_country != "" ? [1] : []
    content {
      priority    = 800
      action      = "deny(403)"
      description = "Só ${var.allowed_country}"
      match {
        expr {
          expression = "origin.region_code != '${var.allowed_country}'"
        }
      }
    }
  }

  # Limite de requisições por IP com banimento temporário
  rule {
    priority    = 900
    action      = "rate_based_ban"
    description = "Mais de ${var.rate_limit} req/min por IP: bane por 5 minutos"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action   = "allow"
      exceed_action    = "deny(429)"
      enforce_on_key   = "IP"
      ban_duration_sec = 300
      rate_limit_threshold {
        count        = var.rate_limit
        interval_sec = 60
      }
    }
  }

  # Regras WAF pré-configuradas (SQL injection, XSS, LFI...)
  dynamic "rule" {
    for_each = var.waf_rules
    content {
      priority    = rule.value
      action      = "deny(403)"
      preview     = var.waf_preview
      description = "WAF ${rule.key}"
      match {
        expr {
          expression = "evaluatePreconfiguredWaf('${rule.key}', {'sensitivity': 1})"
        }
      }
    }
  }

  rule {
    priority    = 2147483647
    action      = "allow"
    description = "Regra padrão"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

resource "google_compute_managed_ssl_certificate" "lab" {
  count   = var.enable_https ? 1 : 0
  project = var.project_id
  name    = "cert-lab"
  managed {
    domains = [local.https_domain]
  }
}
