terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    # Le o certificado do issuer OIDC para o thumbprint do provedor de IRSA.
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
