# Estado isolado por lab (um state por ciclo de vida).
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Este lab cria o próprio bucket de state: primeiro apply com estado local,
  # depois terraform init -migrate-state para o S3.
  backend "local" {}
}
