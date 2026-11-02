terraform {
  required_version = ">= 1.9" # validações que cruzam variáveis

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
