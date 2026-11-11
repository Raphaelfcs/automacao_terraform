terraform {
  required_version = ">= 1.9" # validação que cita outra variável

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
  }
}
