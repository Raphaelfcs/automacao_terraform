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

# Métricas dos health checks do Route 53 só existem em us-east-1 (alarmes ficam lá).
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = local.tags
  }
}
