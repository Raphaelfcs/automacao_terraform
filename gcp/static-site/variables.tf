variable "project_id" {
  description = "ID do projeto GCP onde os buckets serão criados."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (devel ou stage)."
  type        = string

  validation {
    condition     = contains(["devel", "stage"], var.environment)
    error_message = "environment deve ser 'devel' ou 'stage'."
  }
}

variable "app_name" {
  description = "Nome curto da aplicação, usado no nome dos buckets (minúsculas, números e hífen)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,20}[a-z0-9]$", var.app_name))
    error_message = "app_name: 3-22 caracteres, minúsculas, números e hífen."
  }
}

variable "location" {
  description = "Região/multirregião dos buckets (ex.: US, SOUTHAMERICA-EAST1)."
  type        = string
  default     = "US"
}

variable "public_access_enabled" {
  description = "true = site aberto à Internet (janela de teste). false = fechado (public access prevention enforced)."
  type        = bool
  default     = false
}

variable "site_source_dir" {
  description = "Diretório local com os arquivos do build. null = não faz upload."
  type        = string
  default     = null
}

variable "main_page_suffix" {
  description = "Página principal do site."
  type        = string
  default     = "index.html"
}

variable "not_found_page" {
  description = "Página de erro 404."
  type        = string
  default     = "404.html"
}

variable "enable_versioning" {
  description = "Habilita versionamento de objetos no bucket do site (rollback)."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs de acesso no bucket de auditoria."
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 1
    error_message = "log_retention_days deve ser >= 1."
  }
}

variable "force_destroy" {
  description = "Permite destruir buckets com objetos (true em laboratório; false em produção)."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels adicionais aplicadas aos buckets."
  type        = map(string)
  default     = {}
}

variable "extra_objects" {
  description = "Objetos gerados pela IaC: caminho -> conteúdo (ex.: { \"config.json\" = jsonencode(...) }), publicados sem cache."
  type        = map(string)
  default     = {}
}

variable "assets_cache_control" {
  description = "Cache-Control dos arquivos que não são HTML/JSON."
  type        = string
  default     = "public, max-age=3600"
}
