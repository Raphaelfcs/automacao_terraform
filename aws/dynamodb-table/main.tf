# Tabela DynamoDB on-demand pronta para produção: chave (pk, sk), índices globais, stream
# opcional (NEW_AND_OLD_IMAGES) para integração orientada a eventos, PITR, cifra com KMS do
# cliente, proteção contra exclusão e TTL opcional.

resource "aws_dynamodb_table" "this" {
  name                        = var.name
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = var.hash_key
  range_key                   = var.range_key
  deletion_protection_enabled = var.deletion_protection
  stream_enabled              = var.stream_view_type != null
  stream_view_type            = var.stream_view_type
  table_class                 = var.table_class

  dynamic "attribute" {
    for_each = local.attributes
    content {
      name = attribute.key
      type = attribute.value
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.key
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute == null ? [] : [1]
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  tags = merge(var.tags, { Name = var.name })
}
