# Identidade: dois pools do Cognito. Equipe das clínicas com MFA obrigatório; pacientes com MFA
# opcional. Ninguém se cadastra sozinho: a clínica cria o acesso do paciente e a plataforma cria o
# administrador da clínica. Tier Essentials por causa do login gerenciado em português.

module "equipe" {
  source                 = "../../../../../aws/cognito-user-pool"
  name_prefix            = "${local.nome}-equipe"
  domain_prefix          = "${local.nome}-equipe"
  callback_urls          = ["https://${var.dominio_app}/"]
  logout_urls            = ["https://${var.dominio_app}/"]
  mfa_configuration      = "ON"
  admin_create_user_only = true
  user_pool_tier         = "ESSENTIALS"
  advanced_security_mode = "OFF"
  tags                   = local.tags
}

module "pacientes" {
  source                 = "../../../../../aws/cognito-user-pool"
  name_prefix            = "${local.nome}-pacientes"
  domain_prefix          = "${local.nome}-pacientes"
  callback_urls          = ["https://${var.dominio_app}/"]
  logout_urls            = ["https://${var.dominio_app}/"]
  mfa_configuration      = var.mfa_pacientes
  admin_create_user_only = true
  user_pool_tier         = "ESSENTIALS"
  advanced_security_mode = "OFF"
  tags                   = local.tags
}

output "emissores" {
  description = "Emissores aceitos pelas APIs das duas nuvens (variável EMISSORES)."
  value = jsonencode([
    { iss = module.equipe.issuer_uri, tipo = "equipe", client_ids = [module.equipe.web_client_id] },
    { iss = module.pacientes.issuer_uri, tipo = "paciente", client_ids = [module.pacientes.web_client_id] },
  ])
}

output "pool_equipe_id" {
  value = module.equipe.user_pool_id
}

output "pool_pacientes_id" {
  value = module.pacientes.user_pool_id
}

output "pool_arns" {
  value = [module.equipe.user_pool_arn, module.pacientes.user_pool_arn]
}

output "config_web" {
  description = "Bloco cognito do config.json do front."
  value = {
    equipe   = { dominio = module.equipe.hosted_ui_domain, client_id = module.equipe.web_client_id }
    paciente = { dominio = module.pacientes.hosted_ui_domain, client_id = module.pacientes.web_client_id }
  }
}
