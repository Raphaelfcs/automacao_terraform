# Engines sempre por tag imutável: atualizar é um PR que troca o ?ref.
module "resource_group" {
  source = "git::https://git.example.com/plataforma/iac.git//engines/azure/resource-group?ref=engines/azure/resource-group/v1.0.0"

  projeto           = local.projeto
  ambiente          = var.ambiente
  location          = var.location
  bloquear_exclusao = contains(["prd", "dr"], var.ambiente)
  tags              = local.tags
}

output "resource_group" {
  value = module.resource_group.name
}
