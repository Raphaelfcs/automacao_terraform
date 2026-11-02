# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "helm" {}

mock_provider "kubernetes" {}

mock_provider "kubectl" {}

run "exemplo_basico" {
  command = apply

  variables {
    gitops_repo_url       = "git@github.com:minha-org/gitops.git"
    gitops_repo_ssh_key   = "valor-de-teste"
    gitops_bootstrap_path = "clusters/dev"
    hostname              = "argocd.dev.example.com"
  }
}
