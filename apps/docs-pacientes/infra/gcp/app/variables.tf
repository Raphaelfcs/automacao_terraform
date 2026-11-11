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

variable "projeto_gcp" {
  description = "Projeto do GCP do ambiente."
  type        = string
}

variable "regiao_gcp" {
  description = "Região GCP dos dados (residência no Brasil)."
  type        = string
  default     = "southamerica-east1"
}

variable "estado_aws_bucket" {
  description = "Bucket S3 dos estados da AWS (leitura das saídas de outros roots)."
  type        = string
}

variable "estado_gcp_bucket" {
  description = "Bucket GCS dos estados do GCP (leitura das saídas de outros roots)."
  type        = string
}

variable "imagem" {
  description = "Imagem do app no Artifact Registry, com tag imutável (o pipeline passa o SHA do commit)."
  type        = string
}

variable "max_instancias_api" {
  description = "Teto de instâncias da API (custo e carga)."
  type        = number
  default     = 10
}

variable "paises_permitidos" {
  description = "Países que acessam a API (Cloud Armor). Vazio = todos."
  type        = list(string)
  default     = ["BR"]
}
