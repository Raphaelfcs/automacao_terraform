# Exemplo "lambdas" do módulo gcp/workload-identity-aws: Workload Identity Federation AWS -> Google Cloud.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "google" {
  project        = local.project_id
  region         = local.region
  default_labels = local.labels
}

module "workload_identity_aws" {
  source = "../.."

  project_id         = local.project_id
  pool_id            = "aws-dev"
  aws_account_id     = "123456789012"
  aws_role_names     = ["demo-dev-replicador"]
  service_account_id = "demo-dev-aws"
  project_roles      = ["roles/datastore.user"]
}
