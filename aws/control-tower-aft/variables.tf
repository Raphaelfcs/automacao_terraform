variable "ct_management_account_id" {
  description = "Conta de gerenciamento do Control Tower (onde o módulo é aplicado)."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.ct_management_account_id))
    error_message = "ID de conta com 12 dígitos."
  }
}

variable "log_archive_account_id" {
  description = "Conta Log Archive da landing zone."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.log_archive_account_id))
    error_message = "ID de conta com 12 dígitos."
  }
}

variable "audit_account_id" {
  description = "Conta Audit da landing zone."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.audit_account_id))
    error_message = "ID de conta com 12 dígitos."
  }
}

variable "aft_management_account_id" {
  description = "Conta dedicada ao AFT (criada antes pela Account Factory, ver control-tower-account-vending)."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aft_management_account_id))
    error_message = "ID de conta com 12 dígitos."
  }
}

variable "ct_home_region" {
  description = "Home region do Control Tower (a mesma do provider que aplica o módulo)."
  type        = string
}

variable "tf_backend_secondary_region" {
  description = "Região da réplica do backend de estado do AFT (recuperação de desastre)."
  type        = string
}

variable "vcs_provider" {
  description = "Provedor dos repositórios: github, githubenterprise, gitlab, gitlabselfmanaged, bitbucket, azuredevops ou codecommit."
  type        = string
  default     = "github"

  validation {
    condition     = contains(["github", "githubenterprise", "gitlab", "gitlabselfmanaged", "bitbucket", "azuredevops", "codecommit"], var.vcs_provider)
    error_message = "Provedor de VCS não suportado pelo AFT."
  }
}

variable "repository_owner" {
  description = "Organização/usuário dono dos repositórios (ignorado para codecommit)."
  type        = string
  default     = null
}

variable "repositories" {
  description = "Nomes dos quatro repositórios do AFT (sem o dono)."
  type = object({
    account_request                     = string
    global_customizations               = string
    account_customizations              = string
    account_provisioning_customizations = string
  })
  default = {
    account_request                     = "aft-account-request"
    global_customizations               = "aft-global-customizations"
    account_customizations              = "aft-account-customizations"
    account_provisioning_customizations = "aft-account-provisioning-customizations"
  }
}

variable "repo_branch" {
  description = "Branch observada nos quatro repositórios."
  type        = string
  default     = "main"
}

variable "terraform_version" {
  description = "Versão do Terraform usada nos pipelines do AFT."
  type        = string
  default     = "1.12.2"
}

variable "enable_vpc" {
  description = "Cria VPC, NAT Gateways e VPC endpoints na conta do AFT. false = CodeBuild/Lambda fora de VPC (custo fixo perto de zero)."
  type        = bool
  default     = false
}

variable "codebuild_compute_type" {
  description = "Tamanho do CodeBuild dos pipelines do AFT."
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "maximum_concurrent_customizations" {
  description = "Customizações de conta em paralelo."
  type        = number
  default     = 5
}

variable "concurrent_account_factory_actions" {
  description = "Ações simultâneas na Account Factory."
  type        = number
  default     = 5
}

variable "log_retention_days" {
  description = "Retenção dos log groups do AFT (0 = sem expiração)."
  type        = number
  default     = 90
}

variable "log_archive_expiration_days" {
  description = "Expiração dos objetos de log do AFT nos buckets (dias)."
  type        = number
  default     = 365
}

variable "delete_default_vpcs" {
  description = "Remove as VPCs padrão das contas novas (reduz superfície e evita custo acidental)."
  type        = bool
  default     = true
}

variable "cloudtrail_data_events" {
  description = "Liga data events do CloudTrail (S3/Lambda) nas contas — custo alto, desligado por padrão."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags adicionais."
  type        = map(string)
  default     = {}
}
