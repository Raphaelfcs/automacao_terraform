# Chave do Cloud KMS (CMEK) com rotação automática e permissão de uso só para quem precisa
# (agentes de serviço do Cloud Storage, Firestore etc.). Chaves do Cloud KMS não são apagadas de
# verdade: destruir agenda a destruição das versões, por isso o nome é estável por ambiente.

resource "google_kms_key_ring" "this" {
  project  = var.project_id
  name     = var.key_ring_name
  location = var.location
}

resource "google_kms_crypto_key" "this" {
  name            = var.key_name
  key_ring        = google_kms_key_ring.this.id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = var.rotation_period

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = var.protection_level
  }

  labels = var.labels
}

resource "google_kms_crypto_key_iam_member" "uso" {
  for_each      = toset(var.encrypter_decrypter_members)
  crypto_key_id = google_kms_crypto_key.this.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = each.value
}
