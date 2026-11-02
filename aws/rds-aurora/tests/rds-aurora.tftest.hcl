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

run "exemplo_postgresql" {
  command = apply

  variables {
    name                   = "demo-teste-pg"
    engine                 = "aurora-postgresql"
    engine_version         = "16.4"
    parameter_group_family = "aurora-postgresql16"
    vpc_id                 = "vpc-0123456789abcdef0"
    subnet_ids             = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    kms_key_arn            = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    database_name          = "app"
    instances              = { "1" = { instance_class = "db.r7g.large", promotion_tier = 0 }, "2" = { instance_class = "db.r7g.large" } }
    tags                   = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "exemplo_mysql" {
  command = apply

  variables {
    name                   = "demo-teste-my"
    engine                 = "aurora-mysql"
    engine_version         = "8.0.mysql_aurora.3.08.0"
    parameter_group_family = "aurora-mysql8.0"
    backtrack_window_hours = 24
    vpc_id                 = "vpc-0123456789abcdef0"
    subnet_ids             = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    kms_key_arn            = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    tags                   = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "exemplo_serverless_v2" {
  command = apply

  variables {
    name                   = "demo-teste-sls"
    engine                 = "aurora-postgresql"
    engine_version         = "16.4"
    parameter_group_family = "aurora-postgresql16"
    serverless_v2          = { min_capacity = 0.5, max_capacity = 8 }
    instances              = { "1" = {} }
    vpc_id                 = "vpc-0123456789abcdef0"
    subnet_ids             = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    kms_key_arn            = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    deletion_protection    = false
    final_snapshot         = false
    tags                   = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "exemplo_avancado" {
  command = apply

  variables {
    name                         = "demo-teste-adv"
    engine                       = "aurora-postgresql"
    engine_version               = "16.4"
    parameter_group_family       = "aurora-postgresql16"
    vpc_id                       = "vpc-0123456789abcdef0"
    subnet_ids                   = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    kms_key_arn                  = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    ingress_security_groups      = { eks = "sg-0123456789abcdef0" }
    ingress_cidrs                = ["10.100.0.0/16"]
    replica_autoscaling          = { min_capacity = 1, max_capacity = 4, target_cpu = 65 }
    enhanced_monitoring_interval = 30
    iam_database_authentication  = true
    backup_retention_period      = 21
    tags                         = { Projeto = "demo", Ambiente = "teste" }
  }
}
