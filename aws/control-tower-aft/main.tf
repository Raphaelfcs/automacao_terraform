# AWS Control Tower Account Factory for Terraform (AFT) com padrões de FinOps e segurança:
# encapsula o módulo oficial (versão fixa) com GitHub privado via CodeConnections, Terraform OSS,
# SEM VPC/NAT/endpoints no AFT (o maior custo fixo do default) e métricas anônimas desligadas.
# Roda autenticado como administrador na conta de gerenciamento do Control Tower; os recursos
# ficam na conta dedicada do AFT. Contas novas passam a nascer por pull request no repositório
# de account requests.

module "aft" {
  # Versão fixa: atualizar o AFT é um PR que troca o ref (e o aft_version abaixo).
  source = "github.com/aws-ia/terraform-aws-control_tower_account_factory?ref=1.23.0"

  # Contas e regiões
  ct_management_account_id    = var.ct_management_account_id
  log_archive_account_id      = var.log_archive_account_id
  audit_account_id            = var.audit_account_id
  aft_management_account_id   = var.aft_management_account_id
  ct_home_region              = var.ct_home_region
  tf_backend_secondary_region = var.tf_backend_secondary_region

  # Repositórios (GitHub: "org/repo", sempre privados)
  vcs_provider                                    = var.vcs_provider
  account_request_repo_name                       = local.repos.account_request
  account_request_repo_branch                     = var.repo_branch
  global_customizations_repo_name                 = local.repos.global_customizations
  global_customizations_repo_branch               = var.repo_branch
  account_customizations_repo_name                = local.repos.account_customizations
  account_customizations_repo_branch              = var.repo_branch
  account_provisioning_customizations_repo_name   = local.repos.account_provisioning_customizations
  account_provisioning_customizations_repo_branch = var.repo_branch

  # Terraform usado pelos pipelines do AFT
  terraform_distribution = "oss"
  terraform_version      = var.terraform_version

  # FinOps: sem VPC, NAT Gateways e VPC endpoints na conta do AFT
  aft_enable_vpc             = var.enable_vpc
  aft_vpc_endpoints          = var.enable_vpc
  aft_codebuild_compute_type = var.codebuild_compute_type

  # Paralelismo e retenções
  maximum_concurrent_customizations                     = var.maximum_concurrent_customizations
  concurrent_account_factory_actions                    = var.concurrent_account_factory_actions
  cloudwatch_log_group_retention                        = tostring(var.log_retention_days)
  log_archive_bucket_object_expiration_days             = var.log_archive_expiration_days
  aft_backend_bucket_access_logs_object_expiration_days = var.log_archive_expiration_days

  # Feature flags
  aft_feature_delete_default_vpcs_enabled = var.delete_default_vpcs
  aft_feature_cloudtrail_data_events      = var.cloudtrail_data_events
  aft_feature_enterprise_support          = false
  aft_metrics_reporting                   = false

  tags = local.tags
}
