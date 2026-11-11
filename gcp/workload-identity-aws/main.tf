# Workload Identity Federation AWS -> Google Cloud, sem chave de conta de serviço: roles IAM da
# AWS (Lambda, ECS, EC2) trocam a própria credencial temporária por um token do GCP e assumem uma
# conta de serviço com papéis mínimos. Só as roles listadas entram (condição no provedor).
# A saída credential_config é o JSON "external_account" que a google-auth lê (não contém segredo).


resource "google_iam_workload_identity_pool" "this" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "AWS ${var.aws_account_id}"
  description               = "Workloads da conta AWS ${var.aws_account_id}"
}

resource "google_iam_workload_identity_pool_provider" "aws" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = "contas-aws"
  display_name                       = "AWS"

  aws {
    account_id = var.aws_account_id
  }

  attribute_mapping = {
    "google.subject"     = "assertion.arn"
    "attribute.aws_role" = "assertion.arn.contains('assumed-role') ? assertion.arn.extract('{account_arn}assumed-role/') + 'assumed-role/' + assertion.arn.extract('assumed-role/{role_name}/') : assertion.arn"
  }

  attribute_condition = "attribute.aws_role in [${join(", ", [for r in local.roles : "'${r}'"])}]"
}

resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Workloads AWS (federação)"
}

resource "google_service_account_iam_member" "federacao" {
  for_each           = toset(local.roles)
  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this.name}/attribute.aws_role/${each.value}"
}

resource "google_project_iam_member" "papeis" {
  for_each = toset(var.project_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.this.email}"
}

# Assinar URLs do Cloud Storage (signBlob) com a própria conta, sem chave exportada.
resource "google_service_account_iam_member" "auto_assinatura" {
  count              = var.allow_self_sign ? 1 : 0
  service_account_id = google_service_account.this.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.this.email}"
}
