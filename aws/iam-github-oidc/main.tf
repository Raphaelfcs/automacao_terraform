# Confiança GitHub Actions -> AWS sem chaves fixas (OIDC). Duas roles por repositório:
#  - plan: leitura, assumível por pull requests e pela branch principal;
#  - deploy: escrita, assumível SOMENTE por jobs em GitHub Environments com aprovação.
# O estado do Terraform fica num bucket existente (veja o módulo tf-backend-bootstrap).

data "aws_caller_identity" "current" {}
