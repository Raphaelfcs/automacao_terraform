# Testes de plano/apply com providers simulados (terraform test, sem credenciais).

mock_provider "aws" {
  mock_resource "aws_controltower_baseline" {
    defaults = {
      arn = "arn:aws:controltower:sa-east-1:123456789012:enabledbaseline/XAHXS7P6C4I453EZC"
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
}

run "exemplo_registrar_ous" {
  command = apply

  variables {
    organizational_units = {
      Infrastructure = { arn = "arn:aws:organizations::123456789012:ou/o-abcd123456/ou-ab12-11111111" }
      Workloads      = { arn = "arn:aws:organizations::123456789012:ou/o-abcd123456/ou-ab12-22222222" }
      Dev            = { arn = "arn:aws:organizations::123456789012:ou/o-abcd123456/ou-ab12-33333333", parent = "Workloads" }
      Prd            = { arn = "arn:aws:organizations::123456789012:ou/o-abcd123456/ou-ab12-44444444", parent = "Workloads" }
    }
    identity_center_enabled_baseline_arn = "arn:aws:controltower:sa-east-1:123456789012:enabledbaseline/XAHCR4CJTSI4W07MZ"
  }

  assert {
    condition     = length(aws_controltower_baseline.level1) == 2 && length(aws_controltower_baseline.level2) == 2
    error_message = "Duas OUs de primeiro nível e duas aninhadas deveriam ser registradas."
  }

  assert {
    condition     = aws_controltower_baseline.level1["Workloads"].baseline_identifier == "arn:aws:controltower:sa-east-1::baseline/17BSJV3IGJ2QSGA2"
    error_message = "O ARN do AWSControlTowerBaseline deveria ser montado pela região do provider."
  }
}

run "arn_invalido" {
  command = plan

  variables {
    organizational_units = { Ruim = { arn = "ou-ab12-11111111" } }
  }

  expect_failures = [var.organizational_units]
}
