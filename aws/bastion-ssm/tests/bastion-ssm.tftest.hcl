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
    environment       = "dev"
    cluster_name      = "demo-dev"
    vpc_id            = "vpc-0123456789abcdef0"
    private_subnet_id = "subnet-0aaa1111bbbb2222c"
    eks_cluster_sg_id = "sg-0123456789abcdef0"
    kubectl_version   = "v1.31.2"
    enable_helm       = true
    enable_k9s        = true
    tags              = { Projeto = "demo", Ambiente = "teste" }
  }
}
