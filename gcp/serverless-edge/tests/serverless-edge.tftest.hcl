mock_provider "google" {
  mock_resource "google_compute_global_address" {
    defaults = {
      address = "34.120.0.10"
    }
  }
  mock_resource "google_certificate_manager_dns_authorization" {
    defaults = {
      dns_resource_record = [{ name = "_acme-challenge.app.example.com.", type = "CNAME", data = "abc.1.authorize.certificatemanager.goog." }]
    }
  }
  mock_resource "google_certificate_manager_certificate_map" {
    defaults = {
      id = "projects/demo-dev/locations/global/certificateMaps/demo-dev-certs"
    }
  }
}

run "borda_api_e_front" {
  command = apply

  variables {
    project_id        = "demo-dev"
    name              = "demo-dev"
    domain            = "app.example.com"
    serverless_neg_id = "projects/demo-dev/regions/southamerica-east1/networkEndpointGroups/demo-dev-api-neg"
    web_bucket_name   = "demo-dev-web"
    allowed_countries = ["BR"]
  }

  assert {
    condition     = length(google_compute_security_policy.api.rule) == 7
    error_message = "4 OWASP + geografia + limite por IP + padrão."
  }

  assert {
    condition     = output.dns_authorization_record.type == "CNAME" && output.ip_address == "34.120.0.10"
    error_message = "Saídas para o DNS."
  }

  assert {
    condition     = google_compute_url_map.https.path_matcher[0].path_rule[0].paths == toset(["/api/*"])
    error_message = "Só /api/* vai para o Cloud Run."
  }

  assert {
    condition     = google_compute_ssl_policy.this.min_tls_version == "TLS_1_2"
    error_message = "TLS 1.2 ou superior."
  }
}

run "sensibilidade_invalida" {
  command = plan

  variables {
    project_id        = "demo-dev"
    name              = "x"
    domain            = "app.example.com"
    serverless_neg_id = "x"
    web_bucket_name   = "x"
    waf_sensitivity   = 9
  }

  expect_failures = [var.waf_sensitivity]
}
