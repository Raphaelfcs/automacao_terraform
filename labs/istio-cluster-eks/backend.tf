terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket  = "demo-tfstate-labs"
    encrypt = true
    key     = "labs/istio-cluster-eks/terraform.tfstate"
    region  = "us-west-2"
  }
}
