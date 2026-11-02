# ── IAM Role da instância ─────────────────────────────────────────────────────
resource "aws_iam_role" "bastion" {
  name = "${var.cluster_name}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.cluster_name}-bastion-profile"
  role = aws_iam_role.bastion.name

  tags = var.tags
}

# Managed policy exigida pelo Session Manager. NUNCA AmazonSSMFullAccess e NUNCA
# acesso a ECR — o bastion não precisa (e não deve) puxar imagens de container.
resource "aws_iam_role_policy_attachment" "bastion_ssm_core" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "bastion_eks_describe" {
  statement {
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = ["arn:aws:eks:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"]
  }
}

resource "aws_iam_role_policy" "bastion_eks_describe" {
  name   = "${var.cluster_name}-bastion-eks-describe"
  role   = aws_iam_role.bastion.id
  policy = data.aws_iam_policy_document.bastion_eks_describe.json
}

# ── Policy inline: CloudWatch Logs para sessões SSM ───────────────────────────
# Escopada exclusivamente ao log group criado por este módulo (ssm.tf).
data "aws_iam_policy_document" "bastion_session_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.bastion_sessions.arn}:*"]
  }
}

resource "aws_iam_role_policy" "bastion_session_logs" {
  name   = "${var.cluster_name}-bastion-session-logs"
  role   = aws_iam_role.bastion.id
  policy = data.aws_iam_policy_document.bastion_session_logs.json
}

# EKS Access Entry: a autorização no cluster vem daqui (a policy IAM acima só permite
# o update-kubeconfig).
resource "aws_eks_access_entry" "bastion" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.bastion.arn
  type          = "STANDARD"

  tags = var.tags
}

resource "aws_eks_access_policy_association" "bastion" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.bastion.arn
  policy_arn    = var.eks_access_policy_arn

  access_scope {
    type = "cluster"
  }
}
