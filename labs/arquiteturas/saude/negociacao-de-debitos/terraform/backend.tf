# Estado isolado por lab (um state por ciclo de vida).
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "demo-tfstate-123456789012"
    key          = "labs/saude/negociacao-de-debitos/terraform.tfstate"
    region       = "sa-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
