locals {
  root_id = data.aws_organizations_organization.this.roots[0].id

  tags = merge({ Gerenciado = "terraform", Camada = "governanca" }, var.tags)

  first_level  = { for k, v in var.organizational_units : k => v if v.parent == "root" }
  second_level = { for k, v in var.organizational_units : k => v if v.parent != "root" }

  ou_ids = merge(
    { for k, ou in aws_organizations_organizational_unit.level1 : k => ou.id },
    { for k, ou in aws_organizations_organizational_unit.level2 : k => ou.id },
  )

  attach_ids = [for t in var.attach_target : t == "root" ? local.root_id : local.ou_ids[t]]

  # ------------------------------------------------------------ SCPs (guardrails preventivos)
  scps = merge(local.base_scps, length(var.create_tag_enforcement) > 0 ? { "exigir-tags-na-criacao" = local.tag_enforcement_scp } : {})

  base_scps = {
    "regiao-permitida" = {
      description = "Nega uso fora das regiões permitidas (residência dos dados), exceto serviços globais"
      statements = [{
        Sid       = "NegarForaDaRegiao"
        Effect    = "Deny"
        NotAction = var.global_services_exempt
        Resource  = "*"
        Condition = {
          StringNotEquals = { "aws:RequestedRegion" = var.allowed_regions }
          ArnNotLike      = { "aws:PrincipalArn" = var.exempt_role_patterns }
        }
      }]
    }
    "proteger-organizacao-e-seguranca" = {
      description = "Impede sair da organização e desligar CloudTrail, GuardDuty, Config, Security Hub e Access Analyzer"
      statements = [
        {
          Sid      = "NaoSairDaOrganizacao"
          Effect   = "Deny"
          Action   = ["organizations:LeaveOrganization"]
          Resource = "*"
        },
        {
          Sid    = "ProtegerServicosDeSeguranca"
          Effect = "Deny"
          Action = [
            "cloudtrail:StopLogging", "cloudtrail:DeleteTrail", "cloudtrail:UpdateTrail", "cloudtrail:PutEventSelectors",
            "guardduty:DeleteDetector", "guardduty:DisassociateFromMasterAccount", "guardduty:DisassociateFromAdministratorAccount", "guardduty:UpdateDetector",
            "config:StopConfigurationRecorder", "config:DeleteConfigurationRecorder", "config:DeleteDeliveryChannel",
            "securityhub:DisableSecurityHub", "securityhub:DisassociateFromAdministratorAccount",
            "access-analyzer:DeleteAnalyzer", "ec2:DeleteFlowLogs",
          ]
          Resource  = "*"
          Condition = { ArnNotLike = { "aws:PrincipalArn" = var.exempt_role_patterns } }
        },
        {
          Sid       = "ProtegerBloqueioPublicoS3"
          Effect    = "Deny"
          Action    = ["s3:PutAccountPublicAccessBlock", "s3:DeleteAccountPublicAccessBlock"]
          Resource  = "*"
          Condition = { ArnNotLike = { "aws:PrincipalArn" = var.exempt_role_patterns } }
        },
      ]
    }
    "negar-usuario-root" = {
      description = "Nega ações do usuário root nas contas-membro"
      statements = [{
        Sid       = "NegarRoot"
        Effect    = "Deny"
        Action    = "*"
        Resource  = "*"
        Condition = { StringLike = { "aws:PrincipalArn" = ["arn:aws:iam::*:root"] } }
      }]
    }
    "exigir-criptografia" = {
      description = "Nega volumes EBS e bancos RDS sem criptografia"
      statements = [
        {
          Sid       = "EbsCriptografado"
          Effect    = "Deny"
          Action    = ["ec2:CreateVolume"]
          Resource  = "*"
          Condition = { Bool = { "ec2:Encrypted" = "false" } }
        },
        {
          Sid       = "RdsCriptografado"
          Effect    = "Deny"
          Action    = ["rds:CreateDBInstance", "rds:CreateDBCluster"]
          Resource  = "*"
          Condition = { Bool = { "rds:StorageEncrypted" = "false" } }
        },
      ]
    }
  }

  tag_policy = {
    tags = { for t in var.required_tags : lower(t) => { tag_key = { "@@assign" = t } } }
  }

  # Nega a CRIAÇÃO de recursos sem as tags obrigatórias (aws:RequestTag). Uma statement por
  # tag: SCP avalia condições de uma statement com AND, e queremos negar se QUALQUER faltar.
  # Evolução das antigas políticas IAM "EC2 não sobe sem tags" e "tag-policy-key".
  tag_enforcement_scp = {
    description = "Nega criacao de recursos sem as tags obrigatorias"
    statements = [
      for tag in var.create_tag_enforcement : {
        Sid      = "ExigirTag${replace(title(replace(tag, "_", " ")), " ", "")}"
        Effect   = "Deny"
        Action   = var.tag_enforced_actions
        Resource = "*"
        Condition = {
          Null       = { "aws:RequestTag/${tag}" = "true" }
          ArnNotLike = { "aws:PrincipalArn" = var.exempt_role_patterns }
        }
      }
    ]
  }
}
