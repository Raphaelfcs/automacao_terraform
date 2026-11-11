# Exemplo "dados" do módulo gcp/kms-key: Cloud KMS: chave CMEK com rotação.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "kms_key" {
  source = "../.."

  project_id                  = local.project_id
  key_ring_name               = "demo-dev"
  key_name                    = "dados"
  encrypter_decrypter_members = ["serviceAccount:service-123456789012@gs-project-accounts.iam.gserviceaccount.com"]
  labels                      = local.labels
}
