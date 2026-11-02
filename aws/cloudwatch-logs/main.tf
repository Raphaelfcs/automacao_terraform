# Log group de aplicação criado pela IaC (com retenção e KMS) e a role IRSA do coletor
# (ex.: Fluent Bit) que só ESCREVE nele.
#
# O grupo nasce aqui, e não no coletor: um log group criado pelo próprio coletor nasce
# "Never expire" — retenção indefinida de dados que podem conter identificadores pessoais,
# e ninguém revisa a retenção de um grupo que já existe. Por isso a role do coletor NÃO
# recebe logs:CreateLogGroup: a negativa mantém o prazo dentro da IaC, onde mudar exige commit.

resource "aws_cloudwatch_log_group" "application" {
  name              = var.log_group_name
  retention_in_days = var.retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.tags, { Name = var.log_group_name })
}
