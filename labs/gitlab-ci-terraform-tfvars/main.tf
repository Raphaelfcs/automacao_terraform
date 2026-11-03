resource "aws_instance" "creating_ec2" {
  ami           = var.ec2_image_id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_keypair_name
  count         = var.ec2_instance_count
  tags = {
    Name = "teste"
  }
}

output "instance_ips" {
  value = [aws_instance.creating_ec2.*.public_ip,
    aws_instance.creating_ec2.*.private_ip
  ]
}