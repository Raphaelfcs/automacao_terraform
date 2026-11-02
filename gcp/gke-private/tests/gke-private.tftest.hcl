# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "google" {
  mock_data "google_project" {
    defaults = {
      number = "123456789012"
    }
  }
}

run "exemplo_basico" {
  command = apply

  variables {
    project_id          = "demo-plataforma-dev"
    region              = "sa-east-1"
    network_self_link   = "projects/demo-plataforma-dev/global/networks/vpc-demo"
    subnet_self_link    = "projects/demo-plataforma-dev/regions/southamerica-east1/subnetworks/sn-gke-sp"
    pods_range_name     = "pods"
    services_range_name = "services"
    maintenance_window  = { start = "2026-01-01T05:00:00Z", end = "2026-01-01T09:00:00Z", recurrence = "FREQ=WEEKLY;BYDAY=SA,SU" }
    labels              = { projeto = "demo", ambiente = "teste" }
  }
}
