variable "project_id" {
  description = "Projeto do GCP."
  type        = string
}

variable "pool_id" {
  description = "ID do workload identity pool (4 a 32 caracteres)."
  type        = string
}

variable "aws_account_id" {
  description = "Conta AWS de onde vêm os workloads."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id deve ter 12 dígitos."
  }
}

variable "aws_role_names" {
  description = "Nomes das roles IAM (não ARNs) que podem assumir a conta de serviço. Nomes previsíveis evitam dependência circular entre os estados."
  type        = list(string)

  validation {
    condition     = length(var.aws_role_names) > 0
    error_message = "Informe ao menos uma role."
  }
}

variable "service_account_id" {
  description = "ID da conta de serviço que os workloads da AWS assumem."
  type        = string
}

variable "project_roles" {
  description = "Papéis de projeto da conta de serviço (mínimo necessário)."
  type        = list(string)
  default     = []
}

variable "allow_self_sign" {
  description = "Permite à conta assinar com a própria identidade (URLs assinadas do Cloud Storage)."
  type        = bool
  default     = false
}
