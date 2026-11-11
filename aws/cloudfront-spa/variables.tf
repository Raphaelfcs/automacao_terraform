variable "name_prefix" {
  description = "Prefixo aplicado aos recursos de hosting."
  type        = string
}

variable "app_name" {
  description = "Nome do front-end. Compõe o nome do bucket e das origens."
  type        = string
}

variable "dist_path" {
  description = "Caminho do build do front-end (deve conter index.html). Rode o build antes do apply; diretório vazio = site vazio. Para publicar por pipeline (aws s3 sync), aponte para um diretório sem index.html."
  type        = string
}

variable "publish_source_maps" {
  description = "Publica os *.map do build (expõem o código-fonte). Produção: false."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Permite destruir o bucket com objetos dentro (true só em sandbox)."
  type        = bool
  default     = false
}

variable "price_class" {
  description = "PriceClass_100, PriceClass_200 ou PriceClass_All (só a All tem borda na América do Sul)."
  type        = string
  default     = "PriceClass_All"
}

variable "aliases" {
  description = "Domínios próprios (CNAMEs) da distribuição. Exige acm_certificate_arn."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "Certificado ACM em us-east-1 para os aliases. null = certificado padrão *.cloudfront.net."
  type        = string
  default     = null
}

variable "web_acl_id" {
  description = "ARN do Web ACL WAFv2 (escopo CLOUDFRONT, us-east-1). null = sem WAF."
  type        = string
  default     = null
}

variable "content_security_policy" {
  description = "Cabeçalho Content-Security-Policy. Vazio = sem CSP. Valide contra o app real: CSP errada quebra o login."
  type        = string
  default     = ""
}

variable "api_path_patterns" {
  description = "Caminhos encaminhados à origem de API (sem cache, com Authorization preservado)."
  type        = list(string)
  default     = ["/api/*"]

  validation {
    condition     = length(var.api_path_patterns) > 0 && alltrue([for p in var.api_path_patterns : startswith(p, "/")])
    error_message = "api_path_patterns precisa de ao menos um caminho, todos começando por '/'."
  }
}

variable "api_origin_domain" {
  description = "Hostname de um load balancer PÚBLICO com a API. Servir a API no mesmo domínio evita mixed content e preflight de CORS. Vazio = sem origem de API."
  type        = string
  default     = ""
}

variable "api_vpc_origin_enabled" {
  description = "Usa um ALB INTERNO como origem via CloudFront VPC origin (nada público na VPC). Flag explícita porque o ARN do ALB é desconhecido no plan quando nasce no mesmo apply."
  type        = bool
  default     = false

  validation {
    condition     = !(var.api_vpc_origin_enabled && trimspace(var.api_origin_domain) != "")
    error_message = "Informe api_origin_domain OU api_vpc_origin_enabled, nunca os dois."
  }

  validation {
    condition     = !var.api_vpc_origin_enabled || (trimspace(var.api_vpc_origin_arn) != "" && trimspace(var.api_vpc_origin_domain) != "")
    error_message = "api_vpc_origin_enabled exige api_vpc_origin_arn e api_vpc_origin_domain."
  }
}

variable "api_vpc_origin_arn" {
  description = "ARN do ALB interno usado como VPC origin."
  type        = string
  default     = ""

  validation {
    condition     = var.api_vpc_origin_arn == "" || can(regex("^arn:aws:elasticloadbalancing:[a-z0-9-]+:[0-9]{12}:loadbalancer/app/", var.api_vpc_origin_arn))
    error_message = "api_vpc_origin_arn deve ser o ARN de um Application Load Balancer."
  }
}

variable "api_vpc_origin_domain" {
  description = "DNS do ALB interno de api_vpc_origin_arn."
  type        = string
  default     = ""
}

variable "api_vpc_origin_protocol_policy" {
  description = "http-only enquanto o ALB interno não tem certificado (tráfego dentro da VPC); https-only com ACM."
  type        = string
  default     = "http-only"

  validation {
    condition     = contains(["http-only", "https-only"], var.api_vpc_origin_protocol_policy)
    error_message = "Use http-only ou https-only."
  }
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}

variable "assets_cache_control" {
  description = "Cache-Control dos arquivos que não são o index.html. O padrão (1 ano, immutable) exige nomes com hash; app sem hash nos nomes usa \"no-cache\"."
  type        = string
  default     = "public, max-age=31536000, immutable"
}

variable "extra_objects" {
  description = "Objetos gerados pela IaC: caminho -> conteúdo (ex.: { \"config.json\" = jsonencode(...) }), publicados sem cache."
  type        = map(string)
  default     = {}
}
