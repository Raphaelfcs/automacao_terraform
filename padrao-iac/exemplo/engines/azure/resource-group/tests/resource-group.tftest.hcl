mock_provider "azurerm" {}

run "nome_e_tags" {
  command = plan
  variables {
    projeto  = "pagamentos"
    ambiente = "dev"
  }
  assert {
    condition     = azurerm_resource_group.this.name == "rg-pagamentos-dev"
    error_message = "Nome fora do padrão."
  }
  assert {
    condition     = azurerm_resource_group.this.tags["gerenciado"] == "terraform"
    error_message = "Tag obrigatória ausente."
  }
}

run "ambiente_invalido" {
  command = plan
  variables {
    projeto  = "pagamentos"
    ambiente = "qa"
  }
  expect_failures = [var.ambiente]
}
