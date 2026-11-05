# Testes de plano/apply com providers simulados (terraform test, sem credenciais).

mock_provider "aws" {
  mock_resource "aws_servicecatalog_provisioned_product" {
    defaults = {
      id     = "pp-abcd1234efgh5"
      status = "AVAILABLE"
      outputs = [
        { key = "AccountId", value = "345678901234", description = "ID da conta" },
        { key = "AccountEmail", value = "aws+demo-aft-management@example.com", description = "E-mail" },
      ]
    }
  }
}

run "exemplo_conta_aft" {
  command = apply

  variables {
    account_name                = "demo-aft-management"
    account_email               = "aws+demo-aft-management@example.com"
    managed_organizational_unit = "AFT"
    sso_user                    = { first_name = "Plataforma", last_name = "AFT" }
  }

  assert {
    condition     = output.account_id == "345678901234"
    error_message = "O ID da conta deveria vir das saídas do produto provisionado."
  }

  assert {
    condition     = aws_servicecatalog_provisioned_product.account.name == "conta-demo-aft-management"
    error_message = "Nome padrão do produto provisionado incorreto."
  }
}

run "nome_invalido" {
  command = plan

  variables {
    account_name                = "Conta Com Espaço"
    account_email               = "x@example.com"
    managed_organizational_unit = "AFT"
    sso_user                    = { first_name = "a", last_name = "b" }
  }

  expect_failures = [var.account_name]
}
