terraform {
  required_version = ">= 1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
  }

  backend "gcs" {} # envs/<ambiente>/backend.hcl: um estado por ambiente e por recurso
}

provider "google" {
  project        = var.projeto_gcp
  region         = var.regiao_gcp
  default_labels = local.labels
}
