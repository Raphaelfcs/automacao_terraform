# Estado remoto separado por módulo e exemplo (um state por ciclo de vida).
terraform {
  required_version = ">= 1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
  }

  backend "gcs" {
    bucket = "demo-plataforma-tfstate"
    prefix = "gcp/cloud-run-service/api"
  }
}
