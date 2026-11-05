# As quatro service roles que o Control Tower assume na conta de gerenciamento. Pelo console elas
# nascem sozinhas; pela API (e portanto pelo Terraform) precisam existir antes da landing zone.

data "aws_partition" "current" {}

locals {
  ct_roles = {
    admin             = { name = "AWSControlTowerAdmin", service = "controltower.amazonaws.com" }
    cloudtrail        = { name = "AWSControlTowerCloudTrailRole", service = "cloudtrail.amazonaws.com" }
    stackset          = { name = "AWSControlTowerStackSetRole", service = "cloudformation.amazonaws.com" }
    config_aggregator = { name = "AWSControlTowerConfigAggregatorRoleForOrganizations", service = "config.amazonaws.com" }
  }
  partition = data.aws_partition.current.partition
}

resource "aws_iam_role" "ct" {
  for_each = local.ct_roles

  name = each.value.name
  path = "/service-role/"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = each.value.service }, Action = "sts:AssumeRole" }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.ct["admin"].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSControlTowerServiceRolePolicy"
}

resource "aws_iam_role_policy" "admin" {
  name = "AWSControlTowerAdminPolicy"
  role = aws_iam_role.ct["admin"].id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Action = "ec2:DescribeAvailabilityZones", Resource = "*" }]
  })
}

resource "aws_iam_role_policy" "cloudtrail" {
  name = "AWSControlTowerCloudTrailRolePolicy"
  role = aws_iam_role.ct["cloudtrail"].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "arn:${local.partition}:logs:*:*:log-group:aws-controltower/CloudTrailLogs:*"
    }]
  })
}

resource "aws_iam_role_policy" "stackset" {
  name = "AWSControlTowerStackSetRolePolicy"
  role = aws_iam_role.ct["stackset"].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = "arn:${local.partition}:iam::*:role/AWSControlTowerExecution"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_aggregator" {
  role       = aws_iam_role.ct["config_aggregator"].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}
