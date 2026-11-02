variable "allowed_regions" {
  description = "Regiões permitidas para dados e cargas (residência de dados)."
  type        = list(string)
  default     = ["sa-east-1"]
}

variable "organizational_units" {
  description = "OUs da organização. parent = \"root\" ou o nome de outra OU de primeiro nível."
  type        = map(object({
    parent = string
  }))
  default = {
    Security       = { parent = "root" }
    Infrastructure = { parent = "root" }
    Workloads      = { parent = "root" }
    Prod           = { parent = "Workloads" }
    NonProd        = { parent = "Workloads" }
    Sandbox        = { parent = "root" }
    Suspended      = { parent = "root" }
  }
}

variable "exempt_role_patterns" {
  description = "Roles isentas das SCPs de proteção (Control Tower, AFT e break-glass)."
  type        = list(string)
  default     = [
    "arn:aws:iam::*:role/AWSControlTowerExecution",
    "arn:aws:iam::*:role/AWSAFTExecution",
    "arn:aws:iam::*:role/stacksets-exec-*",
    "arn:aws:iam::*:role/BreakGlass",
  ]
}

variable "global_services_exempt" {
  description = "Ações de serviços globais que não podem ser bloqueadas pela SCP de região."
  type        = list(string)
  default     = [
    "iam:*", "organizations:*", "sts:*", "support:*", "route53:*", "route53domains:*", "cloudfront:*",
    "waf:*", "wafv2:*", "shield:*", "budgets:*", "ce:*", "cur:*", "health:*", "trustedadvisor:*",
    "sso:*", "sso-directory:*", "identitystore:*", "kms:*", "account:*", "globalaccelerator:*",
    "networkmanager:*", "directconnect:*", "aws-portal:*", "tag:*", "pricing:*", "s3:GetAccountPublic*",
    "s3:ListAllMyBuckets", "s3:PutAccountPublic*", "controltower:*", "servicecatalog:*", "ec2:DescribeRegions",
  ]
}

variable "required_tags" {
  description = "Chaves de tag exigidas pela política de tags (FinOps: custo por unidade)."
  type        = list(string)
  default     = ["CentroCusto", "Ambiente", "Dono", "Dados"]
}

variable "attach_target" {
  description = "Onde anexar as SCPs de proteção: root (toda a organização) ou lista de nomes de OU."
  type        = list(string)
  default     = ["root"]
}

variable "tags" {
  description = "Tags das políticas."
  type        = map(string)
  default     = {}
}

variable "create_tag_enforcement" {
  description = "Tags exigidas NA CRIAÇÃO dos recursos (SCP). Vazio = SCP não criada. Comece em OU de sandbox: SCP errada bloqueia deploys."
  type        = list(string)
  default     = []
}

variable "tag_enforced_actions" {
  description = "Ações de criação sujeitas à exigência de tags (precisam suportar tag-on-create)."
  type        = list(string)
  default = [
    "ec2:RunInstances", "ec2:CreateVolume", "ec2:CreateNatGateway",
    "rds:CreateDBInstance", "rds:CreateDBCluster",
    "eks:CreateCluster", "ecs:CreateService",
    "elasticache:CreateReplicationGroup", "dynamodb:CreateTable",
    "lambda:CreateFunction", "sqs:CreateQueue", "sns:CreateTopic",
    "elasticloadbalancing:CreateLoadBalancer",
  ]
}
