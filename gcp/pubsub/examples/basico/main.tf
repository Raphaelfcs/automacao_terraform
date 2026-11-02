# Exemplo "basico" do módulo gcp/pubsub: Pub/Sub + Cloud Function (notificação).
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

variable "smtp_password" {
  type      = string
  sensitive = true
}

module "pubsub" {
  source = "../.."

  project_id          = "demo-plataforma-dev"
  project_number      = "123456789012"
  region              = local.region
  db_secret_id        = "projects/demo-plataforma-dev/secrets/db-password"
  function_source_dir = "${path.module}/../../src"
  smtp_user           = "notificacoes@example.com"
  smtp_password       = var.smtp_password
  mail_to             = "time@example.com"
  labels              = local.labels
}
