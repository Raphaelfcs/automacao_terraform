# Exemplo "horario-comercial" do módulo aws/autoscaling-schedule: Desligamento agendado de node groups.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "autoscaling_schedule" {
  source = "../.."

  cluster_name        = "demo-dev"
  node_group_names    = { apps = "demo-dev-apps" }
  up_cron             = "0 7 * * MON-FRI"
  down_cron           = "0 20 * * MON-FRI"
  timezone            = "America/Sao_Paulo"
  up_min_size         = 1
  up_desired_capacity = 2
  up_max_size         = 4
}
