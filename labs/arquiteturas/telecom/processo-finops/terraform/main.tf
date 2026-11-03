# Automação do lab "Processo de FinOps".
# Compõe módulos do catálogo; cada módulo continua testado e versionado no próprio diretório.
# Dependências entre módulos são resolvidas pelas saídas (outputs) de um módulo nas entradas do outro.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "cur_focus_export" {
  source = "../../../../../aws/cur-focus-export"

  bucket_name    = "demo-finops-focus-123456789012"
  retention_days = 730
  tags           = local.tags
}

module "finops_cost_report" {
  source = "../../../../../aws/finops-cost-report"

  name_prefix         = local.name_prefix
  bucket_name         = "demo-finops-relatorios-123456789012"
  alert_topic_arn     = "arn:aws:sns:sa-east-1:123456789012:demo-dev-alertas"
  cost_allocation_tag = "CentroCusto"
  tags                = local.tags
}

module "tag_compliance" {
  source = "../../../../../aws/tag-compliance"

  name_prefix     = local.name_prefix
  required_tags   = ["CentroCusto", "Ambiente", "Dono"]
  alert_topic_arn = "arn:aws:sns:sa-east-1:123456789012:demo-dev-alertas"
  tags            = local.tags
}

module "instance_scheduler" {
  source = "../../../../../aws/instance-scheduler"

  name_prefix = local.name_prefix
  start_cron  = "cron(0 8 ? * MON-FRI *)"
  stop_cron   = "cron(0 19 ? * MON-FRI *)"
  tags        = local.tags
}
