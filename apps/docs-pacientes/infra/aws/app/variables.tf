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

variable "regiao" {
  description = "Região AWS dos dados (residência no Brasil)."
  type        = string
  default     = "sa-east-1"
}


variable "estado_aws_bucket" {
  description = "Bucket S3 dos estados da AWS (leitura das saídas de outros roots)."
  type        = string
}

variable "estado_gcp_bucket" {
  description = "Bucket GCS dos estados do GCP (leitura das saídas de outros roots)."
  type        = string
}

variable "zona_dns_id" {
  description = "Zona do Route 53 do domínio (validação do certificado da CloudFront)."
  type        = string
}

variable "paises_permitidos" {
  description = "Países que acessam o app (WAF). Vazio = todos."
  type        = list(string)
  default     = ["BR"]
}
