terraform {
  backend "s3" {
    bucket  = "demo-tfstate-labs"
    encrypt = true
    key     = "labs/istio-cluster-eks/terraform.tfstate"
    region  = "us-west-2"
  }
}