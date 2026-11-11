terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {} # envs/<ambiente>/backend.hcl: um estado por ambiente e por recurso
}

provider "aws" {
  region = var.regiao

  default_tags {
    tags = local.tags
  }
}
