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

run "exemplo_tgw_bgp" {
  command = apply

  variables {
    transit_gateway_route_table_id = "tgw-rtb-0123456789abcdef0"
    vpn_connections = {
      matriz = {
        target_gateway_type = "transit_gateway"
        transit_gateway_id  = "tgw-0123456789abcdef0"
        routing_option      = "dynamic"
        customer_gateway    = { mode = "new", bgp_asn = 65010, ip_address = "203.0.113.10" }
      }
    }
    tags = { Projeto = "demo", Ambiente = "teste" }
  }
}
