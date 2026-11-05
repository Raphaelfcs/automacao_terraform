variable "github_org" {
  description = "Organização ou usuário do GitHub dono do repositório."
  type        = string
}

variable "github_repo" {
  description = "Nome do repositório."
  type        = string
}

variable "default_branch" {
  description = "Branch principal (pode assumir a role de plan)."
  type        = string
  default     = "main"
}

variable "allowed_environments" {
  description = "GitHub Environments que podem assumir a role de deploy (configure aprovação manual neles)."
  type        = list(string)
  default     = ["sandbox"]
}

variable "allow_pull_requests" {
  description = "Permite que PRs assumam a role de leitura (terraform plan)."
  type        = bool
  default     = true
}

variable "deploy_policy_arns" {
  description = "Políticas da role de deploy. Sandbox: PowerUser + IAM limitado. Produção: políticas específicas."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}

variable "managed_role_prefix" {
  description = "Prefixo das roles IAM que o deploy pode criar/alterar (ex.: \"app-\"). null = nenhuma."
  type        = string
  default     = null
}

variable "permissions_boundary_arn" {
  description = "Permissions boundary aplicado à role de deploy."
  type        = string
  default     = null
}

variable "state_bucket_arn" {
  description = "ARN do bucket de estado do Terraform. null = sem política de estado."
  type        = string
  default     = null
}

variable "plan_assume_role_arns" {
  description = "Roles (em outras contas) que a role de plan pode assumir, ex.: arn:aws:iam::*:role/infra-reader. Vazio = nenhuma."
  type        = list(string)
  default     = []
}

variable "create_oidc_provider" {
  description = "Cria o OIDC provider do GitHub (apenas um por conta)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags adicionais."
  type        = map(string)
  default     = {}
}
