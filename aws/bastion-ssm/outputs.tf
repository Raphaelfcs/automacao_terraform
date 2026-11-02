output "bastion_instance_id" {
  description = "ID da instância EC2 do bastion"
  value       = aws_instance.bastion.id
}

output "bastion_private_ip" {
  description = "IP privado da instância bastion — o bastion nunca tem IP público"
  value       = aws_instance.bastion.private_ip
}

output "bastion_security_group_id" {
  description = "ID do security group do bastion — zero regras de ingress"
  value       = aws_security_group.bastion.id
}

output "bastion_iam_role_arn" {
  description = "ARN da role IAM do bastion — mesmo principal do EKS Access Entry"
  value       = aws_iam_role.bastion.arn
}

output "bastion_ssm_start_command" {
  description = "Comando pronto para abrir uma sessão Session Manager na instância"
  value       = "aws ssm start-session --target ${aws_instance.bastion.id} --region ${data.aws_region.current.region}"
}
