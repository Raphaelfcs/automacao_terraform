locals {
  name       = var.name_prefix
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
  tags       = merge({ Gerenciado = "terraform", Camada = "seguranca" }, var.tags)

  standards_arns = [for s in var.securityhub_standards : "arn:aws:securityhub:${local.region}::${s}"]

  # alertas: GuardDuty alto/crítico e Security Hub HIGH/CRITICAL de qualquer conta
  alert_patterns = {
    guardduty = {
      source        = ["aws.guardduty"]
      "detail-type" = ["GuardDuty Finding"]
      detail        = { severity = [{ numeric = [">=", var.guardduty_min_severity] }] }
    }
    securityhub = {
      source        = ["aws.securityhub"]
      "detail-type" = ["Security Hub Findings - Imported"]
      detail        = {
        findings = {
          Severity    = { Label = ["HIGH", "CRITICAL"] }
          Workflow    = { Status = ["NEW"] }
          RecordState = ["ACTIVE"]
        }
      }
    }
  }
}
