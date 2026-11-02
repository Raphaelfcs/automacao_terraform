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

run "exemplo_mysql" {
  command = apply

  variables {
    name_prefix             = "demo-teste"
    engine                  = "mysql"
    engine_version          = "8.4.3"
    instance_class          = "db.t4g.micro"
    vpc_id                  = "vpc-0123456789abcdef0"
    subnet_ids              = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    kms_key_arn             = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    database_name           = "app"
    ingress_security_groups = { eks = "sg-0123456789abcdef0" }
    deletion_protection     = false
    final_snapshot          = false
    tags                    = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "exemplo_postgres_multi_az" {
  command = apply

  variables {
    name_prefix                  = "demo-teste"
    engine                       = "postgres"
    engine_version               = "16.4"
    instance_class               = "db.r7g.large"
    multi_az                     = true
    vpc_id                       = "vpc-0123456789abcdef0"
    subnet_ids                   = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    kms_key_arn                  = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    database_name                = "app"
    backup_retention_period      = 14
    enhanced_monitoring_interval = 60
    tags                         = { Projeto = "demo", Ambiente = "teste" }
  }
}
