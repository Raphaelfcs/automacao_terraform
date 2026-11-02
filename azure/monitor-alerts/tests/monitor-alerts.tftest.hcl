# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id       = "00000000-0000-0000-0000-000000000000"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      object_id       = "00000000-0000-0000-0000-000000000001"
    }
  }
}

run "exemplo_vm_e_banco" {
  command = apply

  variables {
    resource_group_name     = "rg-monitoria"
    action_group_name       = "ag-plataforma"
    action_group_short_name = "plataforma"
    emails                  = ["plataforma@example.com"]
    metric_alerts = {
      cpu-alta = { target_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app/providers/Microsoft.Compute/virtualMachines/vm-app-01"], metric_namespace = "Microsoft.Compute/virtualMachines", metric_name = "Percentage CPU", threshold = 85 }
      dtu-alta = { target_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dados/providers/Microsoft.Sql/servers/sql-demo/databases/app"], metric_namespace = "Microsoft.Sql/servers/databases", metric_name = "cpu_percent", threshold = 80, severity = 1 }
    }
    tags = { Projeto = "demo", Ambiente = "teste" }
  }
}
