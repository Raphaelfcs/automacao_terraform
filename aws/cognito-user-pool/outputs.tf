locals {
  hosted_domain = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.region}.amazoncognito.com"
  issuer        = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
}

output "user_pool_id" {
  description = "ID do user pool."
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "ARN do user pool."
  value       = aws_cognito_user_pool.this.arn
}

output "web_client_id" {
  description = "Client ID público do front-end."
  value       = aws_cognito_user_pool_client.web.id
}

output "issuer_uri" {
  description = "Issuer OIDC — configure nos resource servers que validam o JWT."
  value       = local.issuer
}

output "jwks_uri" {
  description = "Endpoint JWKS para validar a assinatura do token."
  value       = "${local.issuer}/.well-known/jwks.json"
}

output "hosted_ui_domain" {
  description = "Domínio do login gerenciado."
  value       = local.hosted_domain
}

output "token_uri" {
  description = "Endpoint /oauth2/token (troca de client_credentials por token)."
  value       = "${local.hosted_domain}/oauth2/token"
}

output "service_client_ids" {
  description = "Mapa serviço -> client_id."
  value       = { for k, c in aws_cognito_user_pool_client.service : k => c.id }
}

output "service_client_secrets" {
  description = "Mapa serviço -> client_secret (sensível: grave no Secrets Manager)."
  value       = { for k, c in aws_cognito_user_pool_client.service : k => c.client_secret }
  sensitive   = true
}
