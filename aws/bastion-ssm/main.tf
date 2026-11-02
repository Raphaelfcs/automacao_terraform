# Bastion "SSM-only" para administrar um cluster EKS privado: subnet privada, sem IP
# público, sem key pair, SG sem ingress, IMDSv2, disco cifrado, sessões auditadas no
# CloudWatch e acesso ao cluster por EKS Access Entry. Ferramentas (kubectl, awscli,
# helm, k9s, stern, grpcurl) instaladas por user data com versões fixadas.
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


# ── Resolução da AMI ───────────────────────────────────────────────────────────
# Se var.ami_id = null, resolve a AMI Amazon Linux 2023 mais recente via SSM
# parameter. Recomendado fixar ami_id nos tfvars para evitar replace por drift de AMI.
data "aws_ssm_parameter" "al2023_ami" {
  count = var.ami_id == null ? 1 : 0

  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# ── Instância bastion ──────────────────────────────────────────────────────────
#
# Subnet privada, sem IP público, sem key pair, sem regra de ingress no SG.
# O único caminho de acesso é Session Manager. user_data_replace_on_change = true:
# o bastion é cattle, não pet — qualquer mudança no bootstrap recria a instância.
resource "aws_instance" "bastion" {
  ami           = local.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id

  associate_public_ip_address = false
  # key_name intencionalmente omitido — acesso é exclusivamente via SSM.

  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 obrigatório
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    kms_key_id            = var.kms_key_id
    delete_on_termination = true
  }

  credit_specification {
    cpu_credits = "standard" # nunca "unlimited" — evita custo surpresa
  }

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/templates/user_data.sh.tftpl", {
    kubectl_version = var.kubectl_version
    awscli_version  = var.awscli_version
    enable_grpcurl  = var.enable_grpcurl
    enable_helm     = var.enable_helm
    enable_k9s      = var.enable_k9s
    enable_stern    = var.enable_stern
    cluster_name    = var.cluster_name
    aws_region      = data.aws_region.current.region
    environment     = var.environment
  })

  tags = merge(var.tags, {
    Name        = "${var.cluster_name}-bastion"
    Environment = var.environment
  })

  lifecycle {
    precondition {
      condition     = contains(var.allowed_environments, var.environment)
      error_message = <<-EOT
        Modulo 'bastion' nao homologado para o ambiente '${var.environment}'.
        Ambientes permitidos: ${join(", ", var.allowed_environments)}.
        Em producao prefira acesso via IAM Identity Center + RBAC/GitOps;
        habilitar um bastion com cluster-admin em producao exige decisao registrada.
      EOT
    }
  }
}
