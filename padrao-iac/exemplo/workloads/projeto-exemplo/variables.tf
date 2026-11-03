variable "ambiente" {
  description = "Ambiente deste deploy (vem do terraform.tfvars de envs/<ambiente>)."
  type        = string
}

variable "location" {
  description = "Região do Azure."
  type        = string
  default     = "brazilsouth"
}
