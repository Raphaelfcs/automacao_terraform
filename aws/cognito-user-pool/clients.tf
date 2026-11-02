# Cliente público do front-end: authorization code + PKCE, sem client secret.
resource "aws_cognito_user_pool_client" "web" {
  name         = "${var.name_prefix}-web"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 1

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true
}

# Resource server com os escopos de máquina. O Cognito prefixa cada escopo com o
# identificador no claim `scope` (ex.: api-interna/billing.read): o código que valida o
# token precisa esperar exatamente esse prefixo, ou toda chamada responde 403.
resource "aws_cognito_resource_server" "internal" {
  count = length(var.machine_scopes) > 0 ? 1 : 0

  identifier   = var.resource_server_identifier
  name         = "${var.name_prefix}-internal-api"
  user_pool_id = aws_cognito_user_pool.this.id

  dynamic "scope" {
    for_each = var.machine_scopes
    content {
      scope_name        = scope.key
      scope_description = scope.value
    }
  }
}

# Um cliente por serviço, só com os escopos que ele consome (menor privilégio por construção).
resource "aws_cognito_user_pool_client" "service" {
  for_each = var.service_clients

  name         = "${var.name_prefix}-svc-${each.key}"
  user_pool_id = aws_cognito_user_pool.this.id

  # client_credentials exige segredo. Grave-o no Secrets Manager; nunca em values/.env/ConfigMap.
  generate_secret = true

  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = [for s in each.value : "${var.resource_server_identifier}/${s}"]
  supported_identity_providers         = ["COGNITO"]

  access_token_validity = 60

  token_validity_units {
    access_token = "minutes"
  }

  prevent_user_existence_errors = "ENABLED"
  enable_token_revocation       = true

  depends_on = [aws_cognito_resource_server.internal]

  lifecycle {
    precondition {
      condition     = alltrue([for s in each.value : contains(keys(var.machine_scopes), s)])
      error_message = "service_clients[${each.key}] pede escopo não declarado em machine_scopes."
    }
  }
}
