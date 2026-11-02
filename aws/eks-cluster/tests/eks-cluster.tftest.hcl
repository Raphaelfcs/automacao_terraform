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

mock_provider "tls" {}

run "exemplo_basico" {
  command = apply

  variables {
    cluster_name       = "demo-dev"
    kubernetes_version = "1.31"
    subnet_ids         = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    kms_key_arn        = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    node_pools = {
      sistema = { instance_types = ["t3.medium"], desired_size = 2, min_size = 1, max_size = 3, labels = { role = "system" }, taints = [{ key = "CriticalAddonsOnly", value = "true", effect = "NO_SCHEDULE" }] }
      apps    = { instance_types = ["m7i.large"], desired_size = 2, min_size = 2, max_size = 10 }
    }
    tags = { Projeto = "demo", Ambiente = "teste" }
  }
}

run "exemplo_access_entries" {
  command = apply

  variables {
    cluster_name            = "demo-prd"
    kubernetes_version      = "1.31"
    subnet_ids              = ["subnet-0aaa1111bbbb2222c", "subnet-0ddd3333eeee4444f"]
    kms_key_arn             = "arn:aws:kms:sa-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    bootstrap_creator_admin = false
    access_entries = {
      plataforma = { principal_arn = "arn:aws:iam::123456789012:role/AWSReservedSSO_PlatformAdmin_abc123", policy = "AmazonEKSClusterAdminPolicy" }
      leitura    = { principal_arn = "arn:aws:iam::123456789012:role/AWSReservedSSO_ReadOnly_def456", policy = "AmazonEKSViewPolicy", namespaces = ["apps"] }
    }
    pre_node_addons            = ["vpc-cni"]
    addon_configuration_values = { "vpc-cni" = jsonencode({ env = { WARM_IP_TARGET = "2" } }) }
    tags                       = { Projeto = "demo", Ambiente = "teste" }
  }
}
