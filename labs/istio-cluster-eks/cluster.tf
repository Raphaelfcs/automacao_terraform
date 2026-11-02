resource "aws_instance" "kubernetesmaster" {
  count           = 3
  ami             = var.AWS_AMI
  instance_type   = "%{ if var.ENV == "prod" || var.ENV == "stress-test" }${var.AWS_TYPE_INSTANCE}%{ else }t2.micro%{ endif }"
  key_name        = var.KEYEC2
  security_groups = ["${aws_security_group.kube.id}"]
  subnet_id       = var.SUBNET_EC2

  root_block_device {
    volume_size           = var.SIZE_VOLUME
    volume_type           = var.TYPE_VOLUME
    delete_on_termination = true
  }
  user_data = <<-EOF
                  #!/bin/bash
                  sudo apt-get update -y
                  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common python awscli ansible
                  sudo sed 's/ansible_host_key_checking: False//' > /etc/ansible/ansible.cfg
                  mkfs -t ext4 /dev/xvdh
                  mkdir /opt/mount1
                  mount /dev/xvdh /opt
                  echo /dev/xvdh  /opt ext4 defaults,nofail 0 2 >> /etc/fstab
                  EOF



  tags = {
    Name = "KUBERNETES_MASTER_${var.ENV}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

