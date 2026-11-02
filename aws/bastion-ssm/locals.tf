locals {
  ami_id = var.ami_id != null ? var.ami_id : data.aws_ssm_parameter.al2023_ami[0].value
}
