# Estado remoto separado por módulo e exemplo (um state por ciclo de vida).
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Bootstrap: o primeiro apply usa estado local; depois migre com
  # terraform init -migrate-state apontando para o bucket criado.
  backend "local" {}
}
