# Automação do lab "Monitoria do guia de programação".
# Lambda agendada compara a lista oficial de canais com o guia do dia, avisa por e-mail (SES)
# e publica a métrica CanaisAusentes; um alarme no CloudWatch avisa o NOC pelo SNS.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

# Remetente verificado no SES (domínio ou e-mail).
resource "aws_sesv2_email_identity" "remetente" {
  email_identity = local.remetente
}

data "aws_iam_policy_document" "ses" {
  statement {
    sid       = "EnviaRelatorio"
    actions   = ["ses:SendEmail"]
    resources = [aws_sesv2_email_identity.remetente.arn]
  }
}

module "lambda_function" {
  source = "../../../aws/lambda-function"

  function_name       = "${local.name_prefix}-monitoria-guia"
  description         = "Compara canais oficiais com o guia do dia e avisa quando algum some"
  source_dir          = "${path.module}/src"
  handler             = "app.lambda_handler"
  timeout             = 60
  schedule_expression = "cron(0 9,15,21 * * ? *)" # 06h, 12h e 18h em Brasília
  policy_json         = data.aws_iam_policy_document.ses.json
  environment = {
    URL_CANAIS    = local.url_canais
    URL_GUIA      = local.url_guia
    REMETENTE     = local.remetente
    DESTINATARIOS = join(",", local.destinatarios)
    NIVEL_LOG     = "INFO"
  }
  tags = local.tags
}

module "sns_topic" {
  source = "../../../aws/sns-topic"

  name_prefix        = "${local.name_prefix}-"
  topic_names        = ["noc"]
  publisher_services = ["cloudwatch.amazonaws.com"]
  subscriptions      = { noc = [for d in local.destinatarios : { protocol = "email", endpoint = d }] }
  tags               = local.tags
}

# Alarme pela métrica EMF que a função grava a cada execução.
resource "aws_cloudwatch_metric_alarm" "canais_ausentes" {
  alarm_name          = "${local.name_prefix}-guia-canais-ausentes"
  alarm_description   = "Algum canal da lista oficial não aparece no guia do dia"
  namespace           = "MonitoriaGuia"
  metric_name         = "CanaisAusentes"
  statistic           = "Maximum"
  period              = 3600
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "breaching" # se a função parar de rodar, o alarme também avisa
  alarm_actions       = [module.sns_topic.topic_arns["noc"]]
  ok_actions          = [module.sns_topic.topic_arns["noc"]]
}
