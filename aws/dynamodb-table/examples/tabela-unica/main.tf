# Exemplo "tabela-unica" do módulo aws/dynamodb-table: DynamoDB on-demand com stream, PITR e KMS.
# Ambiente, região e tags ficam em locals.tf; o estado remoto em backend.tf.

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

module "dynamodb_table" {
  source = "../.."

  name             = "${local.name_prefix}-itens"
  kms_key_arn      = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
  stream_view_type = "NEW_AND_OLD_IMAGES"
  global_secondary_indexes = {
    por_paciente = { hash_key = "paciente_sub", range_key = "sk" }
  }
  tags = local.tags
}
