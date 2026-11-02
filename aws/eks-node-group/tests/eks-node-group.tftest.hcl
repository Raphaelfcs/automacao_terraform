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

run "exemplo_sistema_e_apps" {
  command = apply

  variables {
    cluster_name            = "demo-dev"
    node_role_arn           = "arn:aws:iam::123456789012:role/demo-dev-node"
    subnet_ids              = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    node_security_group_ids = ["sg-0123456789abcdef0"]
    kms_key_arn             = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    node_groups = {
      system = { instance_types = ["t3.medium"], desired_size = 2, min_size = 1, max_size = 3, taints = [{ key = "CriticalAddonsOnly", value = "true", effect = "NO_SCHEDULE" }] }
      apps   = { instance_types = ["m7i.large", "m6i.large"], capacity_type = "SPOT", desired_size = 2, min_size = 0, max_size = 10, disk_size = 100, cluster_autoscaler = true }
    }
    tags = { Projeto = "demo", Ambiente = "teste" }
  }
}
