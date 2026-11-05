# Testes de plano com o módulo oficial do AFT substituído (override_module): valida as entradas,
# as validações e a montagem dos nomes de repositório sem baixar credenciais nem criar nada.

override_module {
  target = module.aft
}

run "exemplo_github_sem_vpc" {
  command = plan

  variables {
    ct_management_account_id    = "123456789012"
    log_archive_account_id      = "210987654321"
    audit_account_id            = "222233334444"
    aft_management_account_id   = "345678901234"
    ct_home_region              = "sa-east-1"
    tf_backend_secondary_region = "us-east-1"
    vcs_provider                = "github"
    repository_owner            = "demo-org"
  }

  assert {
    condition     = output.repositories.account_request == "demo-org/aft-account-request"
    error_message = "Repositórios GitHub deveriam ser montados como <org>/<repo>."
  }
}

run "conta_invalida" {
  command = plan

  variables {
    ct_management_account_id    = "123"
    log_archive_account_id      = "210987654321"
    audit_account_id            = "222233334444"
    aft_management_account_id   = "345678901234"
    ct_home_region              = "sa-east-1"
    tf_backend_secondary_region = "us-east-1"
    repository_owner            = "demo-org"
  }

  expect_failures = [var.ct_management_account_id]
}
