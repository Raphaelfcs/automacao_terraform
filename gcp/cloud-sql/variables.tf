variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "network_id" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "sql-lab"
}

variable "tier" {
  description = "db-f1-micro para laboratório; use db-custom-* em produção."
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "ZONAL (laboratório) ou REGIONAL (alta disponibilidade)."
  type        = string
  default     = "ZONAL"
}

variable "database" {
  type    = string
  default = "orders"
}

variable "db_user" {
  type    = string
  default = "app"
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "labels" {
  type    = map(string)
  default = {}
}
