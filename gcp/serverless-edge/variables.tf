variable "project_id" {
  description = "Projeto do GCP."
  type        = string
}

variable "name" {
  description = "Prefixo dos recursos da borda."
  type        = string
}

variable "domain" {
  description = "Nome publicado (ex.: app.example.com). O certificado sai por autorização de DNS."
  type        = string
}

variable "serverless_neg_id" {
  description = "NEG serverless do Cloud Run da API (saída neg_id do módulo cloud-run-service)."
  type        = string
}

variable "web_bucket_name" {
  description = "Bucket com o build do front (objetos legíveis pelo Load Balancer)."
  type        = string
}

variable "waf_rule_ids" {
  description = "Regras WAF pré-configuradas do Cloud Armor (cada uma cobra como regra)."
  type        = list(string)
  default     = ["sqli-v33-stable", "xss-v33-stable", "lfi-v33-stable", "rce-v33-stable"]
}

variable "waf_sensitivity" {
  description = "Sensibilidade das regras OWASP (1 = menos falso positivo, 4 = mais rígido)."
  type        = number
  default     = 1

  validation {
    condition     = var.waf_sensitivity >= 1 && var.waf_sensitivity <= 4
    error_message = "waf_sensitivity entre 1 e 4."
  }
}

variable "waf_preview" {
  description = "Regras WAF só registram, sem bloquear (primeira semana em produção)."
  type        = bool
  default     = false
}

variable "rate_limit_per_minute" {
  description = "Requisições por IP por minuto antes do banimento de 5 minutos."
  type        = number
  default     = 300
}

variable "allowed_countries" {
  description = "Códigos ISO de países permitidos na API (ex.: [\"BR\"]). Vazio = sem restrição."
  type        = list(string)
  default     = []
}

variable "content_security_policy" {
  description = "CSP enviada com o front. Precisa permitir o domínio do login e os buckets de upload."
  type        = string
  default     = "default-src 'self'; frame-ancestors 'none'; base-uri 'none'; object-src 'none'"
}

variable "log_sample_rate" {
  description = "Fração das requisições da API registradas no log do LB (0 a 1)."
  type        = number
  default     = 1
}
