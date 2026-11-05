variable "zone_name" {
  description = "Domínio da zona (ex.: example.com ou dev.example.com), sem ponto final."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9]([a-z0-9-]*[a-z0-9])?\\.)+[a-z]{2,}$", var.zone_name))
    error_message = "Use um domínio em minúsculas, sem ponto final."
  }
}

variable "comment" {
  description = "Comentário da zona."
  type        = string
  default     = "Gerenciada por Terraform"
}

variable "create_wildcard_certificate" {
  description = "Emite certificado ACM para o domínio e *.domínio, validado nesta zona. Para CloudFront, aplique com provider em us-east-1."
  type        = bool
  default     = true
}

variable "wait_for_validation" {
  description = "Espera o ACM validar o certificado. Em subdomínio novo, só valida depois que a delegação NS existir na zona pai."
  type        = bool
  default     = false
}

variable "certificate_key_algorithm" {
  description = "Algoritmo da chave do certificado."
  type        = string
  default     = "EC_prime256v1"
}

variable "caa_issuers" {
  description = "Autoridades autorizadas a emitir certificados (registro CAA). Vazio = sem CAA."
  type        = list(string)
  default     = ["amazon.com", "amazontrust.com", "awstrust.com", "amazonaws.com"]
}

variable "tags" {
  description = "Tags adicionais."
  type        = map(string)
  default     = {}
}
