# Node groups gerenciados com launch template próprio: IMDSv2 obrigatório (hop limit 2
# para pods que usam o IMDS), volume gp3 cifrado e SG de nó explícito. Use quando o
# node group "simples" do módulo eks-cluster não basta (SG customizado, disco, user data).

resource "aws_launch_template" "this" {
  for_each = var.node_groups

  name_prefix            = "${var.cluster_name}-${each.key}-"
  vpc_security_group_ids = var.node_security_group_ids

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = each.value.disk_size
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.kms_key_arn
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.cluster_name}-${each.key}-node" })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(var.tags, { Name = "${var.cluster_name}-${each.key}-volume" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-${each.key}"
  node_role_arn   = var.node_role_arn
  subnet_ids      = coalesce(each.value.subnet_ids, var.subnet_ids)
  instance_types  = each.value.instance_types
  capacity_type   = each.value.capacity_type
  ami_type        = each.value.ami_type

  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = aws_launch_template.this[each.key].latest_version
  }

  labels = merge({ role = each.key }, each.value.labels)

  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(var.tags, { Name = "${var.cluster_name}-${each.key}" }, each.value.cluster_autoscaler ? {
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  } : {})

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
