variable "name" {
  description = "Nome do budget (prefixo da SCP e da role da ação)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,60}$", var.name))
    error_message = "Use minúsculas, números e hífen."
  }
}

variable "limit_usd" {
  description = "Teto mensal em dólares."
  type        = number

  validation {
    condition     = var.limit_usd > 0
    error_message = "O teto precisa ser maior que zero."
  }
}

variable "linked_account_ids" {
  description = "Filtra o budget por contas-membro (na conta de gerenciamento). Vazio = toda a fatura."
  type        = list(string)
  default     = []
}

variable "alerts" {
  description = "Alertas: percentual do teto e tipo (ACTUAL = gasto real, FORECASTED = previsão do mês)."
  type = list(object({
    percent = number
    type    = string
  }))
  default = [
    { percent = 50, type = "ACTUAL" },
    { percent = 80, type = "ACTUAL" },
    { percent = 100, type = "FORECASTED" },
  ]

  validation {
    condition     = alltrue([for a in var.alerts : contains(["ACTUAL", "FORECASTED"], a.type)])
    error_message = "type deve ser ACTUAL ou FORECASTED."
  }
}

variable "alert_emails" {
  description = "E-mails que recebem os alertas e a notificação da ação."
  type        = list(string)

  validation {
    condition     = length(var.alert_emails) > 0 && length(var.alert_emails) <= 10
    error_message = "Informe de 1 a 10 e-mails."
  }
}

variable "alert_sns_topic_arns" {
  description = "Tópicos SNS que também recebem os alertas (ex.: chat da equipe)."
  type        = list(string)
  default     = []
}

variable "freeze_target_ids" {
  description = "OUs/contas que recebem a SCP de congelamento ao atingir o teto. Vazio = sem ação automática."
  type        = list(string)
  default     = []
}

variable "freeze_at_percent" {
  description = "Percentual do teto (gasto real) que dispara o congelamento."
  type        = number
  default     = 100
}

variable "freeze_approval_model" {
  description = "AUTOMATIC aplica a SCP sozinho; MANUAL espera aprovação no console do Budgets."
  type        = string
  default     = "AUTOMATIC"

  validation {
    condition     = contains(["AUTOMATIC", "MANUAL"], var.freeze_approval_model)
    error_message = "Use AUTOMATIC ou MANUAL."
  }
}

variable "freeze_actions" {
  description = "Ações negadas durante o congelamento (criar/ligar recursos que geram custo)."
  type        = list(string)
  default = [
    "ec2:RunInstances", "ec2:StartInstances", "ec2:CreateNatGateway", "ec2:AllocateAddress",
    "sagemaker:CreateEndpoint", "sagemaker:UpdateEndpoint", "sagemaker:UpdateEndpointWeightsAndCapacities",
    "sagemaker:CreateTrainingJob", "sagemaker:CreateProcessingJob", "sagemaker:CreateNotebookInstance",
    "bedrock:CreateProvisionedModelThroughput",
    "rds:CreateDBInstance", "rds:CreateDBCluster", "rds:StartDBInstance", "rds:StartDBCluster",
    "ecs:CreateService", "eks:CreateCluster", "eks:CreateNodegroup",
    "elasticache:CreateReplicationGroup", "elasticache:CreateCacheCluster",
    "redshift:CreateCluster", "opensearch:CreateDomain", "es:CreateDomain",
  ]
}

variable "exempt_role_patterns" {
  description = "Roles que continuam podendo agir durante o congelamento (Control Tower, AFT, break-glass)."
  type        = list(string)
  default = [
    "arn:aws:iam::*:role/AWSControlTowerExecution",
    "arn:aws:iam::*:role/AWSAFTExecution",
    "arn:aws:iam::*:role/BreakGlass",
  ]
}

variable "tags" {
  description = "Tags adicionais."
  type        = map(string)
  default     = {}
}
