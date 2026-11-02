# Cabeçalhos de segurança (HSTS, nosniff, frame DENY, referrer, CSP opcional).
resource "aws_cloudfront_response_headers_policy" "this" {
  name    = "${var.name_prefix}-${var.app_name}-security-headers"
  comment = "Cabecalhos de seguranca de ${var.app_name}"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    xss_protection {
      protection = true
      mode_block = true
      override   = true
    }

    dynamic "content_security_policy" {
      for_each = trimspace(var.content_security_policy) != "" ? [var.content_security_policy] : []

      content {
        content_security_policy = content_security_policy.value
        override                = true
      }
    }
  }
}
