variable "organizational_units" {
  description = "OUs a registrar, por nome: ARN da OU e, para OUs aninhadas, o nome da OU pai (que também precisa estar no mapa ou já registrada)."
  type = map(object({
    arn    = string
    parent = optional(string)
  }))

  validation {
    condition     = alltrue([for v in values(var.organizational_units) : can(regex("^arn:aws[a-z-]*:organizations::[0-9]{12}:ou/o-[a-z0-9]+/ou-[a-z0-9]+-[a-z0-9]+$", v.arn))])
    error_message = "Cada OU precisa de um ARN de OU válido (arn:aws:organizations::<conta>:ou/o-.../ou-...)."
  }
}

variable "identity_center_enabled_baseline_arn" {
  description = "ARN do baseline do Identity Center já habilitado pela landing zone (obrigatório quando o accessManagement está ligado). Obtenha com: aws controltower list-enabled-baselines."
  type        = string
  default     = null
}

variable "baseline_version" {
  description = "Versão do AWSControlTowerBaseline (acompanha a versão da landing zone)."
  type        = string
  default     = "4.0"
}

variable "baseline_arn" {
  description = "ARN do AWSControlTowerBaseline. null = monta pelo identificador padrão da AWS na região do provider."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags adicionais."
  type        = map(string)
  default     = {}
}
