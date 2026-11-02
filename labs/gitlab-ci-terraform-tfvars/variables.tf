variable ec2_region {
  default = "us-east-1"
}

variable ec2_keypair_name {
  default = "gitlab-ssh"
}

variable ec2_instance_type {
    default = "t2.micro"
}

variable ec2_image_id {
    default = "ami-033b95fb8079dc481"
}

variable ec2_tags {
    type = map(string)
    default     = {}
}

variable "ec2_instance_count" {
    default = "1"
}