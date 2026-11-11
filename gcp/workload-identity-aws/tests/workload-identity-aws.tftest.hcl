mock_provider "google" {
  mock_resource "google_iam_workload_identity_pool" {
    defaults = {
      name = "projects/123456789012/locations/global/workloadIdentityPools/aws-prd"
    }
  }
  mock_resource "google_iam_workload_identity_pool_provider" {
    defaults = {
      name = "projects/123456789012/locations/global/workloadIdentityPools/aws-prd/providers/aws"
    }
  }
  mock_resource "google_service_account" {
    defaults = {
      email = "demo-dev-aws@demo-dev.iam.gserviceaccount.com"
      name  = "projects/demo-dev/serviceAccounts/demo-dev-aws@demo-dev.iam.gserviceaccount.com"
    }
  }
}

run "lambdas_acessam_gcp" {
  command = apply

  variables {
    project_id         = "demo-dev"
    pool_id            = "aws-prd"
    aws_account_id     = "123456789012"
    aws_role_names     = ["demo-dev-replicador", "demo-dev-api"]
    service_account_id = "demo-dev-aws"
    project_roles      = ["roles/datastore.user"]
  }

  assert {
    condition     = google_iam_workload_identity_pool_provider.aws.attribute_condition == "attribute.aws_role in ['arn:aws:sts::123456789012:assumed-role/demo-dev-replicador', 'arn:aws:sts::123456789012:assumed-role/demo-dev-api']"
    error_message = "Só as roles listadas entram."
  }

  assert {
    condition     = jsondecode(output.credential_config).credential_source.environment_id == "aws1" && !can(jsondecode(output.credential_config).private_key)
    error_message = "Config external_account sem segredo."
  }

  assert {
    condition     = length(google_service_account_iam_member.federacao) == 2
    error_message = "Uma permissão de impersonação por role."
  }
}

run "conta_invalida" {
  command = plan

  variables {
    project_id         = "demo-dev"
    pool_id            = "aws"
    aws_account_id     = "12345"
    aws_role_names     = ["x"]
    service_account_id = "demo-dev-aws"
  }

  expect_failures = [var.aws_account_id]
}
