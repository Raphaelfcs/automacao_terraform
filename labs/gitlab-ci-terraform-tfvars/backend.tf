terraform {
  backend "s3" {
    bucket = "demo-tfstate-labs"
    key    = "labs/gitlab-ci-terraform-tfvars/terraform.tfstate"
    region = "us-east-1"
  }
}