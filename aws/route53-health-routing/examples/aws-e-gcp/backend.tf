# Estado remoto separado por módulo e exemplo (um state por ciclo de vida).
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
    key          = "aws/route53-health-routing/aws-e-gcp/terraform.tfstate"
    region       = "sa-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
