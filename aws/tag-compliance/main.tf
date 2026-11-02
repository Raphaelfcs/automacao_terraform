# Conformidade de tags orientada a eventos: CloudTrail -> EventBridge -> Lambda.
# Redesenho em Terraform das antigas automações boto3 (autotag de EC2, validação de tags,
# parada de RDS sem tag) com permissões mínimas, logs com retenção e alerta por SNS.

module "function" {
  source = "../lambda-function"

  function_name = "${var.name_prefix}-tag-compliance"
  description   = "Valida tags obrigatorias em EC2/RDS recem-criados"
  source_dir    = "${path.module}/src"
  handler       = "app.lambda_handler"
  timeout       = 60
  kms_key_arn   = var.kms_key_arn

  environment = {
    REQUIRED_TAGS = join(",", var.required_tags)
    OWNER_TAG     = var.owner_tag
    MODE          = var.enforce ? "ENFORCE" : "NOTIFY"
    TOPIC_ARN     = var.alert_topic_arn
  }

  policy_json = data.aws_iam_policy_document.function.json

  event_patterns = {
    criacao = {
      source        = ["aws.ec2", "aws.rds"]
      "detail-type" = ["AWS API Call via CloudTrail"]
      detail = {
        eventName = ["RunInstances", "CreateDBInstance", "CreateDBCluster"]
      }
    }
  }

  tags = var.tags
}
