# Exemplo "itens" do módulo gcp/firestore-database: Firestore nativo com CMEK, PITR e backups.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "firestore_database" {
  source = "../.."

  project_id = local.project_id
  kms_key_id = "projects/demo-plataforma-dev/locations/southamerica-east1/keyRings/demo-dev/cryptoKeys/dados"
  composite_indexes = {
    tenant = { collection = "itens", fields = [{ path = "pk" }, { path = "sk" }] }
  }
}
