variable "ambiente" {
  description = "Ambiente (dev, hml, prd). Vem de envs/<ambiente>/terraform.tfvars."
  type        = string

  validation {
    condition     = contains(["dev", "hml", "prd"], var.ambiente)
    error_message = "ambiente deve ser dev, hml ou prd."
  }
}

variable "dominio_app" {
  description = "Nome publicado do app (o mesmo nas duas nuvens)."
  type        = string
}

variable "estado_aws_bucket" {
  description = "Bucket S3 dos estados da AWS (leitura das saídas de outros roots)."
  type        = string
}

variable "estado_gcp_bucket" {
  description = "Bucket GCS dos estados do GCP (leitura das saídas de outros roots)."
  type        = string
}

variable "regiao" {
  description = "Região padrão do provider."
  type        = string
  default     = "sa-east-1"
}

variable "zona_dns_id" {
  description = "Zona do Route 53 do domínio."
  type        = string
}

variable "peso_aws" {
  description = "Peso da AWS no DNS (0 a 255). Peso igual nas duas = ativo-ativo meio a meio."
  type        = number
  default     = 50
}

variable "peso_gcp" {
  description = "Peso do GCP no DNS (0 a 255)."
  type        = number
  default     = 50
}

variable "emails_alerta" {
  description = "E-mails que recebem o alarme de nuvem fora do DNS."
  type        = list(string)
  default     = []
}
