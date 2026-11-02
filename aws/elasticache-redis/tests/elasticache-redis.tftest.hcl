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
    name_prefix             = "demo-teste"
    vpc_id                  = "vpc-0123456789abcdef0"
    subnet_ids              = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    kms_key_arn             = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    engine_version          = "8.0"
    node_type               = "cache.t4g.micro"
    ingress_security_groups = { eks = "sg-0123456789abcdef0" }
    tags                    = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "exemplo_alta_disponibilidade" {
  command = apply

  variables {
    name_prefix              = "demo-teste"
    vpc_id                   = "vpc-0123456789abcdef0"
    subnet_ids               = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    kms_key_arn              = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    engine_version           = "8.0"
    node_type                = "cache.r7g.large"
    replica_count            = 2
    snapshot_retention_limit = 7
    tags                     = { Projeto = "demo", Ambiente = "teste" }
  }
}
