mock_provider "aws" {
  mock_resource "aws_dynamodb_table" {
    defaults = {
      arn        = "arn:aws:dynamodb:sa-east-1:123456789012:table/demo-dev-itens"
      stream_arn = "arn:aws:dynamodb:sa-east-1:123456789012:table/demo-dev-itens/stream/2026-11-11T00:00:00.000"
    }
  }
}

run "tabela_unica_com_indice_e_stream" {
  command = apply

  variables {
    name             = "demo-dev-itens"
    kms_key_arn      = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    stream_view_type = "NEW_AND_OLD_IMAGES"
    global_secondary_indexes = {
      por_paciente = { hash_key = "paciente_sub", range_key = "sk" }
    }
  }

  assert {
    condition     = length(aws_dynamodb_table.this.attribute) == 3
    error_message = "Atributos devem ser só pk, sk e paciente_sub."
  }

  assert {
    condition     = aws_dynamodb_table.this.point_in_time_recovery[0].enabled && aws_dynamodb_table.this.deletion_protection_enabled
    error_message = "PITR e proteção contra exclusão ligados por padrão."
  }

  assert {
    condition     = aws_dynamodb_table.this.stream_enabled && output.stream_arn != null
    error_message = "Stream ligado."
  }

  assert {
    condition     = output.index_arns == ["arn:aws:dynamodb:sa-east-1:123456789012:table/demo-dev-itens/index/por_paciente"]
    error_message = "ARN do índice para políticas."
  }
}

run "stream_invalido" {
  command = plan

  variables {
    name             = "x"
    kms_key_arn      = "arn:aws:kms:sa-east-1:123456789012:key/x"
    stream_view_type = "TUDO"
  }

  expect_failures = [var.stream_view_type]
}
