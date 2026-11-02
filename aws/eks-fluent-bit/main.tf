# Fluent Bit (DaemonSet) enviando logs de container ao CloudWatch Logs.
# A role IRSA e o log group vêm do módulo cloudwatch-logs (o coletor NÃO cria log group).

resource "helm_release" "fluent_bit" {
  name             = "fluent-bit"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = var.create_namespace

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 300

  values = [yamlencode({
    serviceAccount = {
      create      = true
      name        = var.service_account
      annotations = { "eks.amazonaws.com/role-arn" = var.collector_role_arn }
    }
    tolerations = [{ operator = "Exists" }]
    resources = {
      requests = { cpu = "50m", memory = "64Mi" }
      limits   = { memory = "256Mi" }
    }
    config = {
      service = <<-EOT
        [SERVICE]
            Flush         5
            Log_Level     info
            Parsers_File  /fluent-bit/etc/parsers.conf
            HTTP_Server   On
            HTTP_Listen   0.0.0.0
            HTTP_Port     2020
            Health_Check  On
      EOT
      inputs  = <<-EOT
        [INPUT]
            Name              tail
            Path              /var/log/containers/*.log
            Exclude_Path      ${join(",", [for ns in var.excluded_namespaces : "/var/log/containers/*_${ns}_*.log"])}
            multiline.parser  docker, cri
            Tag               kube.*
            Mem_Buf_Limit     50MB
            Skip_Long_Lines   On
      EOT
      filters = <<-EOT
        [FILTER]
            Name                kubernetes
            Match               kube.*
            Merge_Log           On
            Keep_Log            Off
            K8S-Logging.Parser  On
            K8S-Logging.Exclude On
      EOT
      outputs = <<-EOT
        [OUTPUT]
            Name                cloudwatch_logs
            Match               kube.*
            region              ${var.region}
            log_group_name      ${var.log_group_name}
            log_stream_prefix   ${var.cluster_name}-
            auto_create_group   false
      EOT
    }
  })]
}
