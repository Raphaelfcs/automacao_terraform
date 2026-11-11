mock_provider "google" {
  mock_resource "google_kms_key_ring" {
    defaults = {
      id = "projects/demo-dev/locations/southamerica-east1/keyRings/demo-dev"
    }
  }
  mock_resource "google_kms_crypto_key" {
    defaults = {
      id = "projects/demo-dev/locations/southamerica-east1/keyRings/demo-dev/cryptoKeys/dados"
    }
  }
}

run "chave_para_storage_e_firestore" {
  command = apply

  variables {
    project_id    = "demo-dev"
    key_ring_name = "demo-dev"
    key_name      = "dados"
    encrypter_decrypter_members = [
      "serviceAccount:service-123456789012@gs-project-accounts.iam.gserviceaccount.com",
      "serviceAccount:service-123456789012@gcp-sa-firestore.iam.gserviceaccount.com",
    ]
  }

  assert {
    condition     = google_kms_crypto_key.this.rotation_period == "7776000s"
    error_message = "Rotação de 90 dias por padrão."
  }

  assert {
    condition     = length(google_kms_crypto_key_iam_member.uso) == 2
    error_message = "Só os agentes de serviço informados usam a chave."
  }
}
