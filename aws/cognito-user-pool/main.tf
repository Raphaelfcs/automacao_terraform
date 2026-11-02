# Amazon Cognito como IdP OAuth2/OIDC: pool de usuários (login humano com MFA), grupos
# por papel (RBAC), cliente público do front (authorization code + PKCE) e clientes de
# máquina (client_credentials) com escopos mínimos por serviço.

data "aws_region" "current" {}

resource "aws_cognito_user_pool" "this" {
  name = "${var.name_prefix}-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  mfa_configuration        = var.mfa_configuration
  deletion_protection      = var.deletion_protection ? "ACTIVE" : "INACTIVE"

  software_token_mfa_configuration {
    enabled = var.mfa_configuration != "OFF"
  }

  password_policy {
    minimum_length                   = 12
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 3
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = var.admin_create_user_only
  }

  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  # Atributos customizados (ex.: tenant_id). O tenant é lido do token, nunca do corpo da requisição.
  dynamic "schema" {
    for_each = var.custom_attributes
    content {
      name                     = schema.key
      attribute_data_type      = "String"
      mutable                  = true
      required                 = false
      developer_only_attribute = false

      string_attribute_constraints {
        min_length = 1
        max_length = schema.value
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-users" })
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.this.id

  # Versão 2 = managed login: aceita idioma (?lang=pt-BR) e marca por IaC. A versão 1
  # (hosted UI clássica) sai sempre em inglês.
  managed_login_version = 2
}

resource "aws_cognito_managed_login_branding" "web" {
  user_pool_id = aws_cognito_user_pool.this.id
  client_id    = aws_cognito_user_pool_client.web.id

  use_cognito_provided_values = true
}

# Um grupo por papel. A associação usuário -> grupo é operacional, não versionada.
resource "aws_cognito_user_group" "roles" {
  for_each = var.roles

  name         = each.key
  user_pool_id = aws_cognito_user_pool.this.id
  description  = each.value
}
