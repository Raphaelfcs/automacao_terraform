# Estado isolado por lab (um state por ciclo de vida).
terraform {
  required_version = ">= 1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.10, < 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4"
    }
  }

  backend "gcs" {
    bucket = "demo-plataforma-tfstate"
    prefix = "labs/google-cloud/gke-seguro"
  }
}
