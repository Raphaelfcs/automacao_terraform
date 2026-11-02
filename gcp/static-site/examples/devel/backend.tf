# Estado remoto separado por módulo e exemplo (um state por ciclo de vida).
# =============================================================================
# Módulo filho (engine): static-site
# Cria: bucket do site (website estático) + bucket de logs de acesso (auditoria)
# O código é ÚNICO para todos os ambientes; o ambiente vem só das variáveis.
# =============================================================================
terraform {
  required_version = ">= 1.10"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
  }

  backend "gcs" {
    bucket = "demo-plataforma-tfstate"
    prefix = "gcp/static-site/devel"
  }
}
