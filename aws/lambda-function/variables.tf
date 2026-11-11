variable "function_name" {
  description = "Nome da função."
  type        = string
}

variable "description" {
  description = "Descrição da função."
  type        = string
  default     = ""
}

variable "source_dir" {
  description = "Diretório com o código (empacotado em zip no plan)."
  type        = string
}

variable "handler" {
  description = "Handler (ex.: app.lambda_handler)."
  type        = string
  default     = "app.lambda_handler"
}

variable "runtime" {
  description = "Runtime (ex.: python3.12)."
  type        = string
  default     = "python3.12"
}

variable "architecture" {
  description = "arm64 (Graviton, ~20% mais barato) ou x86_64."
  type        = string
  default     = "arm64"
}

variable "memory_size" {
  description = "Memória em MB (CPU escala junto)."
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Timeout em segundos."
  type        = number
  default     = 60
}

variable "reserved_concurrency" {
  description = "Concorrência reservada (-1 = sem reserva)."
  type        = number
  default     = -1
}

variable "environment" {
  description = "Variáveis de ambiente (nunca segredos: use Secrets Manager/Parameter Store)."
  type        = map(string)
  default     = {}
}

variable "policy_json" {
  description = "Policy document JSON com as permissões específicas da função. Use junto com attach_policy_json = true."
  type        = string
  default     = null
}

variable "attach_policy_json" {
  description = "Cria a policy inline com policy_json. É um booleano separado porque o JSON costuma depender de ARNs que só existem depois do apply, e o count precisa ser conhecido no plan."
  type        = bool
  default     = false
}

variable "permissions_boundary_arn" {
  description = "Permissions boundary da role de execução."
  type        = string
  default     = null
}

variable "vpc" {
  description = "Executa dentro da VPC (subnets privadas + SGs). null = fora da VPC."
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "dead_letter_target_arn" {
  description = "Fila SQS ou tópico SNS para invocações assíncronas que falharam."
  type        = string
  default     = null
}

variable "tracing" {
  description = "Liga AWS X-Ray."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "Chave KMS das variáveis de ambiente e do log group."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Retenção do log group."
  type        = number
  default     = 30
}

variable "schedule_expression" {
  description = "Agenda (ex.: cron(0 22 ? * MON-FRI *) ou rate(1 hour)). null = sem agenda."
  type        = string
  default     = null
}

variable "event_patterns" {
  description = "Regras do EventBridge por nome -> event pattern (objeto)."
  type        = map(any)
  default     = {}
}

variable "sqs_trigger_arn" {
  description = "Fila SQS que dispara a função. null = sem gatilho SQS."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}

variable "dynamodb_stream_arn" {
  description = "Stream do DynamoDB que dispara a função (lotes com falha parcial e bisseção). null = sem gatilho."
  type        = string
  default     = null
}

variable "stream_failure_destination_arn" {
  description = "Fila SQS que recebe a referência dos lotes do stream que esgotaram as retentativas."
  type        = string
  default     = null
}
