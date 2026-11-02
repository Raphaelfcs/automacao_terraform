variable "project_id" {
  type = string
}

variable "project_number" {
  type = string
}

variable "region" {
  type = string
}

variable "topic_name" {
  type    = string
  default = "orders-created"
}

variable "k8s_namespace" {
  description = "Namespace da aplicação que publica no tópico."
  type        = string
  default     = "lab"
}

variable "k8s_service_account" {
  description = "Conta de serviço do Kubernetes que publica no tópico (Workload Identity)."
  type        = string
  default     = "orders-api"
}

variable "db_secret_id" {
  description = "Secret com a senha do banco, lido pela API via Workload Identity."
  type        = string
}

variable "function_name" {
  type    = string
  default = "notify-order"
}

variable "function_source_dir" {
  description = "Pasta com o código da função (main.py + requirements.txt)."
  type        = string
}

variable "smtp_user" {
  description = "Conta Gmail que envia o e-mail."
  type        = string
}

variable "smtp_password" {
  description = "Senha de app do Gmail (fica no Secret Manager)."
  type        = string
  sensitive   = true
}

variable "mail_to" {
  description = "Destinatário da confirmação."
  type        = string
}

variable "labels" {
  type    = map(string)
  default = {}
}
