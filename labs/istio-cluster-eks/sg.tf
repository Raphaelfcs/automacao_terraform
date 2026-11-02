
resource "aws_security_group" "kube" {
  name   = "k8s_multi_${var.ENV}"
  vpc_id = "${var.VPCNAME}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.services_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.RANGE_IPS_SR
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

