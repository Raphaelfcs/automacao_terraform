provider "aws" {
  region                      = var.AWS_REGION
  skip_requesting_account_id  = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  s3_force_path_style         = true
  version                     = "~> 2.0"
}

