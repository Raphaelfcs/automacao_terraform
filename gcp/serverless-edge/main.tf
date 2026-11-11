# Borda global do Google Cloud para app serverless: Load Balancer HTTPS externo (EXTERNAL_MANAGED)
# com certificado gerenciado por autorização de DNS (funciona mesmo com o DNS apontando para outra
# nuvem, como num ativo-ativo), Cloud Armor na API (regras OWASP pré-configuradas e limite por IP),
# /api/* no Cloud Run pelo NEG serverless e o resto no bucket do front com Cloud CDN.

resource "google_compute_global_address" "this" {
  project = var.project_id
  name    = "${var.name}-ip"
}

resource "google_certificate_manager_dns_authorization" "this" {
  project = var.project_id
  name    = "${var.name}-dns-auth"
  domain  = var.domain
}

resource "google_certificate_manager_certificate" "this" {
  project = var.project_id
  name    = "${var.name}-cert"
  scope   = "DEFAULT"

  managed {
    domains            = [var.domain]
    dns_authorizations = [google_certificate_manager_dns_authorization.this.id]
  }
}

resource "google_certificate_manager_certificate_map" "this" {
  project = var.project_id
  name    = "${var.name}-certs"
}

resource "google_certificate_manager_certificate_map_entry" "this" {
  project      = var.project_id
  name         = "${var.name}-entrada"
  map          = google_certificate_manager_certificate_map.this.name
  hostname     = var.domain
  certificates = [google_certificate_manager_certificate.this.id]
}

resource "google_compute_security_policy" "api" {
  project     = var.project_id
  name        = "${var.name}-api"
  description = "WAF e limite por IP da API"
  type        = "CLOUD_ARMOR"

  dynamic "rule" {
    for_each = local.waf_rules
    content {
      priority    = rule.value.priority
      action      = var.waf_preview ? "allow" : "deny(403)"
      preview     = var.waf_preview
      description = "OWASP ${rule.value.id}"
      match {
        expr {
          expression = "evaluatePreconfiguredWaf('${rule.value.id}', {'sensitivity': ${var.waf_sensitivity}})"
        }
      }
    }
  }

  dynamic "rule" {
    for_each = length(var.allowed_countries) > 0 ? [1] : []
    content {
      priority    = 800
      action      = "deny(403)"
      description = "Somente ${join(", ", var.allowed_countries)}"
      match {
        expr {
          expression = "!(${join(" || ", [for c in var.allowed_countries : "origin.region_code == '${c}'"])})"
        }
      }
    }
  }

  rule {
    priority    = 900
    action      = "rate_based_ban"
    description = "Limite por IP com banimento temporário"
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
        count        = var.rate_limit_per_minute
        interval_sec = 60
      }
    }
  }

  rule {
    priority    = 2147483647
    action      = "allow"
    description = "Padrão"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

resource "google_compute_backend_service" "api" {
  project               = var.project_id
  name                  = "${var.name}-api"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.api.id

  backend {
    group = var.serverless_neg_id
  }

  log_config {
    enable      = true
    sample_rate = var.log_sample_rate
  }
}

resource "google_compute_backend_bucket" "web" {
  project     = var.project_id
  name        = "${var.name}-web"
  bucket_name = var.web_bucket_name
  enable_cdn  = true

  cdn_policy {
    cache_mode  = "CACHE_ALL_STATIC"
    default_ttl = 300
    max_ttl     = 3600
  }

  custom_response_headers = local.security_headers
}

resource "google_compute_url_map" "https" {
  project         = var.project_id
  name            = "${var.name}-https"
  default_service = google_compute_backend_bucket.web.id

  host_rule {
    hosts        = [var.domain]
    path_matcher = "app"
  }

  path_matcher {
    name            = "app"
    default_service = google_compute_backend_bucket.web.id

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.api.id
    }
  }
}

resource "google_compute_target_https_proxy" "this" {
  project         = var.project_id
  name            = "${var.name}-https"
  url_map         = google_compute_url_map.https.id
  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.this.id}"
  ssl_policy      = google_compute_ssl_policy.this.id
}

resource "google_compute_ssl_policy" "this" {
  project         = var.project_id
  name            = "${var.name}-tls"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_compute_global_forwarding_rule" "https" {
  project               = var.project_id
  name                  = "${var.name}-https"
  ip_address            = google_compute_global_address.this.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_https_proxy.this.id
}

# Porta 80 só redireciona para HTTPS (conta como segunda regra, dentro das 5 do preço base).
resource "google_compute_url_map" "redirect" {
  project = var.project_id
  name    = "${var.name}-redirect"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "redirect" {
  project = var.project_id
  name    = "${var.name}-redirect"
  url_map = google_compute_url_map.redirect.id
}

resource "google_compute_global_forwarding_rule" "http" {
  project               = var.project_id
  name                  = "${var.name}-http"
  ip_address            = google_compute_global_address.this.address
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.redirect.id
}
