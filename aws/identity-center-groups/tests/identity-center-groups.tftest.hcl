# Testes de plano/apply com providers simulados (terraform test, sem credenciais).

mock_provider "aws" {
  mock_data "aws_ssoadmin_instances" {
    defaults = {
      arns               = ["arn:aws:sso:::instance/ssoins-0123456789abcdef"]
      identity_store_ids = ["d-0123456789"]
    }
  }
}

run "exemplo_grupos_e_usuarios" {
  command = apply

  variables {
    groups = {
      demo-admins = "Administradores"
      demo-finops = "Custos"
    }
    users = {
      "admin@example.com" = { given_name = "Admin", family_name = "Plataforma", groups = ["demo-admins", "demo-finops"] }
    }
  }

  assert {
    condition     = length(aws_identitystore_group_membership.this) == 2
    error_message = "O usuário deveria entrar nos dois grupos."
  }
}

run "grupo_inexistente" {
  command = plan

  variables {
    groups = { demo-admins = "Administradores" }
    users  = { "a@example.com" = { given_name = "A", family_name = "B", groups = ["nao-existe"] } }
  }

  expect_failures = [var.users]
}
