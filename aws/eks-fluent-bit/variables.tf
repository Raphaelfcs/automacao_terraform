variable "cluster_name" {
  description = "Nome do cluster (prefixo dos log streams)."
  type        = string
}

variable "region" {
  description = "Região do CloudWatch Logs."
  type        = string
}

variable "log_group_name" {
  description = "Log group de destino (criado pelo módulo cloudwatch-logs)."
  type        = string
}

variable "collector_role_arn" {
  description = "Role IRSA do coletor (output collector_role_arn do módulo cloudwatch-logs)."
  type        = string
}

variable "namespace" {
  description = "Namespace do release (deve casar com a trust policy da role)."
  type        = string
  default     = "observability"
}

variable "service_account" {
  description = "ServiceAccount do coletor (deve casar com a trust policy da role)."
  type        = string
  default     = "fluent-bit"
}

variable "create_namespace" {
  description = "Cria o namespace se não existir."
  type        = bool
  default     = true
}

variable "chart_version" {
  description = "Versão fixada do chart fluent/fluent-bit."
  type        = string
  default     = "0.47.10"
}

variable "excluded_namespaces" {
  description = "Namespaces cujos logs não são enviados."
  type        = list(string)
  default     = ["kube-system"]
}
