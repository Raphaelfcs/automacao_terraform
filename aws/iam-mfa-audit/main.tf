# Auditoria de MFA: regra gerenciada do AWS Config (contínua) + Lambda semanal que envia
# por SNS o relatório de usuários IAM com console e sem MFA.
# Redesenho da antiga Lambda de MFA que enviava e-mail por SES com destinatários fixos.

resource "aws_config_config_rule" "iam_user_mfa" {
  count = var.create_config_rule ? 1 : 0

  name = "${var.name_prefix}-iam-user-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_MFA_ENABLED"
  }

  maximum_execution_frequency = "TwentyFour_Hours"
  tags                        = var.tags
}

module "function" {
  source = "../lambda-function"

  function_name       = "${var.name_prefix}-iam-mfa-audit"
  description         = "Relatorio semanal de usuarios sem MFA"
  source_dir          = "${path.module}/src"
  timeout             = 120
  kms_key_arn         = var.kms_key_arn
  schedule_expression = var.schedule_expression

  environment = {
    TOPIC_ARN = var.alert_topic_arn
  }

  policy_json = data.aws_iam_policy_document.function.json
  tags        = var.tags
}
