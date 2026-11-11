mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/demo-dev-gcp-api"
    }
  }
}

run "cloud_run_acessa_dynamodb" {
  command = apply

  variables {
    role_name                  = "demo-dev-gcp-api"
    google_service_account_ids = ["112233445566778899001"]
    policy_json                = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"dynamodb:GetItem\",\"Resource\":\"*\"}]}"
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Principal.Federated == "accounts.google.com"
    error_message = "Trust só no provedor OIDC do Google."
  }

  assert {
    condition     = jsondecode(aws_iam_role.this.assume_role_policy).Statement[0].Condition.StringEquals["accounts.google.com:sub"] == ["112233445566778899001"]
    error_message = "Trust amarrada ao ID único da conta de serviço."
  }

  assert {
    condition     = output.role_arn == "arn:aws:iam::123456789012:role/demo-dev-gcp-api"
    error_message = "Saída do ARN."
  }
}

run "email_no_lugar_do_id_e_recusado" {
  command = plan

  variables {
    role_name                  = "x"
    google_service_account_ids = ["api@proj.iam.gserviceaccount.com"]
    policy_json                = "{}"
  }

  expect_failures = [var.google_service_account_ids]
}
