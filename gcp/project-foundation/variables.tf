variable "project_id" {
  description = "ID do projeto do laboratório (único no mundo)."
  type        = string
}

variable "project_name" {
  description = "Nome exibido do projeto."
  type        = string
}

variable "billing_account" {
  description = "ID da conta de faturamento (XXXXXX-XXXXXX-XXXXXX)."
  type        = string
}

variable "org_id" {
  description = "ID numérico da organização. Vazio = conta sem organização (sem pasta e sem Org Policies)."
  type        = string
  default     = ""
}

variable "folder_name" {
  description = "Nome da pasta criada na organização."
  type        = string
  default     = "fldr-lab"
}

variable "apis" {
  description = "APIs habilitadas no projeto."
  type        = list(string)
}

variable "labels" {
  description = "Labels aplicadas ao projeto (base para FinOps)."
  type        = map(string)
  default     = {}
}

variable "boolean_policies" {
  description = "Org Policies booleanas aplicadas na pasta (só com organização)."
  type        = list(string)
  default     = []
}
