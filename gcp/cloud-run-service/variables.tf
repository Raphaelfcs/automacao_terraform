variable "project_id" {
  description = "Projeto do GCP."
  type        = string
}

variable "name" {
  description = "Nome do serviço."
  type        = string
}

variable "region" {
  description = "Região do serviço."
  type        = string
  default     = "southamerica-east1"
}

variable "image" {
  description = "Imagem do container (Artifact Registry), de preferência com digest ou tag imutável."
  type        = string
}

variable "service_account_id" {
  description = "ID da conta de serviço criada para o serviço (6 a 30 caracteres)."
  type        = string
}

variable "ingress" {
  description = "INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY ou INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER."
  type        = string
  default     = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  validation {
    condition     = contains(["INGRESS_TRAFFIC_ALL", "INGRESS_TRAFFIC_INTERNAL_ONLY", "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"], var.ingress)
    error_message = "ingress inválido."
  }
}

variable "env" {
  description = "Variáveis de ambiente (sem segredos: use Secret Manager ou identidade federada)."
  type        = map(string)
  default     = {}
}

variable "min_instances" {
  description = "Instâncias mínimas (0 = escala a zero e não cobra parado)."
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Instâncias máximas (teto de custo e de carga no banco)."
  type        = number
  default     = 20
}

variable "concurrency" {
  description = "Requisições simultâneas por instância."
  type        = number
  default     = 40
}

variable "cpu" {
  description = "vCPU por instância."
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memória por instância."
  type        = string
  default     = "512Mi"
}

variable "timeout_seconds" {
  description = "Tempo máximo por requisição."
  type        = number
  default     = 60
}

variable "invoker_members" {
  description = "Quem pode invocar (ex.: allUsers atrás do LB; serviceAccount do Eventarc em serviço interno)."
  type        = list(string)
  default     = []
}

variable "project_roles" {
  description = "Papéis de projeto da conta de serviço (mínimo necessário)."
  type        = list(string)
  default     = []
}

variable "create_serverless_neg" {
  description = "Cria o NEG serverless para usar o serviço como backend de um Load Balancer."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Impede destruir o serviço pelo Terraform."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels aplicados."
  type        = map(string)
  default     = {}
}
