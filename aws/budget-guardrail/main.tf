# Teto de custo como guardrail (FinOps): AWS Budget mensal com alertas por e-mail/SNS em
# percentuais do valor real e da previsão e, opcionalmente, uma ação automática que aplica uma
# SCP de "congelamento" (nega criar/ligar recursos caros) quando o gasto real atinge o limite.
# Na conta de gerenciamento o budget pode filtrar contas-membro; a SCP congela OUs ou contas.

resource "aws_budgets_budget" "this" {
  name         = var.name
  budget_type  = "COST"
  limit_amount = format("%.2f", var.limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "cost_filter" {
    for_each = length(var.linked_account_ids) > 0 ? [1] : []
    content {
      name   = "LinkedAccount"
      values = var.linked_account_ids
    }
  }

  dynamic "notification" {
    for_each = var.alerts
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value.percent
      threshold_type             = "PERCENTAGE"
      notification_type          = notification.value.type
      subscriber_email_addresses = var.alert_emails
      subscriber_sns_topic_arns  = var.alert_sns_topic_arns
    }
  }

  tags = local.tags
}

resource "aws_organizations_policy" "freeze" {
  count = local.freeze ? 1 : 0

  name        = "${var.name}-congelamento"
  description = "Aplicada pelo AWS Budgets ao atingir o teto: bloqueia criar/ligar recursos caros"
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "CongelarGastos"
      Effect    = "Deny"
      Action    = var.freeze_actions
      Resource  = "*"
      Condition = { ArnNotLike = { "aws:PrincipalArn" = var.exempt_role_patterns } }
    }]
  })
  tags = local.tags
}

resource "aws_budgets_budget_action" "freeze" {
  count = local.freeze ? 1 : 0

  budget_name        = aws_budgets_budget.this.name
  action_type        = "APPLY_SCP_POLICY"
  approval_model     = var.freeze_approval_model
  notification_type  = "ACTUAL"
  execution_role_arn = aws_iam_role.budgets_action[0].arn

  action_threshold {
    action_threshold_type  = "PERCENTAGE"
    action_threshold_value = var.freeze_at_percent
  }

  definition {
    scp_action_definition {
      policy_id  = aws_organizations_policy.freeze[0].id
      target_ids = var.freeze_target_ids
    }
  }

  dynamic "subscriber" {
    for_each = var.alert_emails
    content {
      address           = subscriber.value
      subscription_type = "EMAIL"
    }
  }

  tags = local.tags
}
