# Role IAM assumida por uma conta de serviço do Google Cloud, sem chave de acesso: o workload no
# GCP (Cloud Run, GKE, Cloud Functions) apresenta um ID token do Google e recebe credencial
# temporária via AssumeRoleWithWebIdentity. A trust policy confere o ID único da conta de serviço
# (azp e sub) e a audiência pedida (oaud), então outra conta de serviço do mesmo projeto não entra.

# jsonencode (e não o data source) para a política ser real também nos testes com provider simulado.
locals {
  trust = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = "accounts.google.com" }
      Condition = {
        StringEquals = {
          "accounts.google.com:aud"  = var.google_service_account_ids
          "accounts.google.com:sub"  = var.google_service_account_ids
          "accounts.google.com:oaud" = var.audience
        }
      }
    }]
  })
}

resource "aws_iam_role" "this" {
  name                 = var.role_name
  description          = "Assumida pelo Google Cloud (${join(", ", var.google_service_account_ids)}) via OIDC, sem chave fixa."
  assume_role_policy   = local.trust
  max_session_duration = var.max_session_duration
  permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.role_name}-permissoes"
  role   = aws_iam_role.this.id
  policy = var.policy_json
}
