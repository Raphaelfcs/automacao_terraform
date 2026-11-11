# Exemplo "api-e-eventos" do módulo gcp/service-accounts: Contas de serviço com papéis mínimos.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "service_accounts" {
  source = "../.."

  project_id = local.project_id
  accounts = {
    demo-dev-api = { display_name = "API", project_roles = ["roles/datastore.user"], self_sign = true }
  }
}
