locals {
  # Conta existente (criada em outro estado, ex.: para quebrar dependência circular) ou criada aqui.
  sa_email = coalesce(var.service_account_email, try(google_service_account.this[0].email, null))
}
