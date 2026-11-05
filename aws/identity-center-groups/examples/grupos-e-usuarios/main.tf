# Exemplo "grupos-e-usuarios" do módulo aws/identity-center-groups: grupos por papel e um
# administrador inicial no diretório interno do Identity Center.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "identity_center_groups" {
  source = "../.."

  groups = {
    demo-admins   = "Administradores da plataforma (todas as contas)"
    demo-devs     = "Desenvolvimento: escrita em dev, leitura em prd"
    demo-readonly = "Somente leitura"
    demo-finops   = "Custos e faturamento"
  }

  users = {
    "admin@example.com" = {
      given_name  = "Admin"
      family_name = "Plataforma"
      groups      = ["demo-admins", "demo-finops"]
    }
  }
}
