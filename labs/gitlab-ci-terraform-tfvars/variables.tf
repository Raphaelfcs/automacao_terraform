variable "ec2_region" {
  type    = string
  default = "us-east-1"
}

variable "ec2_keypair_name" {
  type    = string
  default = "gitlab-ssh"
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_image_id" {
  type    = string
  default = "ami-033b95fb8079dc481"
}

variable "ec2_instance_count" {
  type    = number
  default = 1
}