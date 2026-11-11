# Testes de plano/apply com providers simulados (terraform test, sem credenciais).
# Valida que cada exemplo documentado é aceito pelas variáveis e validações do módulo.

mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
      arn        = "arn:aws:iam::123456789012:user/teste"
    }
  }
  mock_data "aws_region" {
    defaults = {
      name   = "sa-east-1"
      region = "sa-east-1"
    }
  }
  mock_data "aws_partition" {
    defaults = {
      partition  = "aws"
      dns_suffix = "amazonaws.com"
    }
  }
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "exemplo_basico" {
  command = apply

  variables {
    bucket_name = "demo-dev-dados-123456789012"
    tags        = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "exemplo_kms_ciclo_de_vida" {
  command = apply

  variables {
    bucket_name = "demo-dev-capturas-123456789012"
    kms_key_arn = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    versioning  = false
    lifecycle_rules = {
      capturas = { prefix = "captures/", expiration_days = 7 }
      arquivo  = { prefix = "arquivo/", transition_days = 30, transition_storage_class = "GLACIER_IR" }
    }
    tags = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "documentos_com_cors_eventos_e_worm" {
  command = plan

  variables {
    bucket_name               = "demo-dev-docs-123456789012"
    kms_key_arn               = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    cors_allowed_origins      = ["https://app.example.com"]
    eventbridge_notifications = true
    object_lock               = { mode = "GOVERNANCE", days = 30 }
  }

  assert {
    condition     = aws_s3_bucket.this.object_lock_enabled == true
    error_message = "Object Lock precisa ser ligado na criação do bucket."
  }

  assert {
    condition     = aws_s3_bucket_object_lock_configuration.this[0].rule[0].default_retention[0].days == 30
    error_message = "Retenção padrão não aplicada."
  }

  assert {
    condition     = aws_s3_bucket_notification.eventbridge[0].eventbridge == true
    error_message = "Eventos do bucket precisam ir para o EventBridge."
  }

  assert {
    condition     = tolist(aws_s3_bucket_cors_configuration.this[0].cors_rule)[0].allowed_origins == toset(["https://app.example.com"])
    error_message = "CORS deve aceitar só a origem do app."
  }
}

run "worm_sem_versionamento_e_recusado" {
  command = plan

  variables {
    bucket_name = "demo-dev-docs-123456789012"
    versioning  = false
    object_lock = { mode = "GOVERNANCE", days = 1 }
  }

  expect_failures = [aws_s3_bucket_object_lock_configuration.this]
}

run "cors_so_https" {
  command = plan

  variables {
    bucket_name          = "demo-dev-docs-123456789012"
    cors_allowed_origins = ["http://app.example.com"]
  }

  expect_failures = [var.cors_allowed_origins]
}
