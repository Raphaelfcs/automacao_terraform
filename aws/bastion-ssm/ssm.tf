# ── Preferências de sessão (SSM-SessionManagerRunShell) ─────────────────────
#
# O documento SSM-SessionManagerRunShell é singleton por conta/região: gerenciá-lo
# afeta toda instância SSM da conta, não apenas o bastion. Por isso fica desligado
# por padrão (var.manage_session_preferences = false). Ligue somente na conta em que
# este módulo é o dono das preferências de sessão.
resource "aws_ssm_document" "session_preferences" {
  count = var.manage_session_preferences ? 1 : 0

  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Preferências de sessão: logs cifrados no CloudWatch e timeout por inatividade."
    sessionType   = "Standard_Stream"
    inputs = {
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.bastion_sessions.name
      cloudWatchEncryptionEnabled = true
      cloudWatchStreamingEnabled  = true
      kmsKeyId                    = var.kms_key_id == null ? "" : var.kms_key_id
      idleSessionTimeout          = "20"
      runAsEnabled                = false
      shellProfile = {
        linux = "cd ~ && bash"
      }
    }
  })

  tags = var.tags
}

# ── CloudWatch Log Group — trilha de auditoria de sessões Session Manager ────
resource "aws_cloudwatch_log_group" "bastion_sessions" {
  name              = "/aws/ssm/${var.cluster_name}-bastion-${var.environment}"
  retention_in_days = var.session_log_retention_days
  kms_key_id        = var.kms_key_id

  tags = merge(var.tags, { Name = "${var.cluster_name}-bastion-${var.environment}-sessions" })
}
