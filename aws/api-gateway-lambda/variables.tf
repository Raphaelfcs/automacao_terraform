variable "name" {
  description = "Nome da API."
  type        = string
}

variable "description" {
  description = "Descrição da API."
  type        = string
  default     = ""
}

variable "lambda_function_name" {
  description = "Nome da Lambda de backend."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "invoke_arn da Lambda de backend."
  type        = string
}

variable "routes" {
  description = "Rotas (\"METODO /caminho\"). \"$default\" captura tudo."
  type        = list(string)
  default     = ["ANY /{proxy+}"]
}

variable "stage_name" {
  description = "Nome do stage (\"$default\" = sem prefixo na URL)."
  type        = string
  default     = "$default"
}

variable "jwt_authorizer" {
  description = "Autorizador JWT (ex.: Cognito: issuer = issuer_uri, audience = [client_id]). null = API aberta."
  type = object({
    issuer   = string
    audience = list(string)
  })
  default = null
}

variable "cors_allow_origins" {
  description = "Origens CORS permitidas. Vazio = sem CORS."
  type        = list(string)
  default     = []
}

variable "integration_timeout_ms" {
  description = "Timeout da integração (máx. 30000)."
  type        = number
  default     = 29000
}

variable "throttling_burst_limit" {
  description = "Burst de requisições."
  type        = number
  default     = 100
}

variable "throttling_rate_limit" {
  description = "Requisições por segundo."
  type        = number
  default     = 50
}

variable "kms_key_arn" {
  description = "Chave KMS do log group de acesso."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Retenção dos logs de acesso."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags aplicadas."
  type        = map(string)
  default     = {}
}
