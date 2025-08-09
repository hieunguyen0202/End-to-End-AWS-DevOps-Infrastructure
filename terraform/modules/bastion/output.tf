# modules/bastion/output.tf

output "bastion_public_ip" {
  description = "The public IP address of the Bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_id" {
  description = "The ID of the Bastion instance"
  value       = aws_instance.bastion.id
}

# output "nginx_private_ip" {
#   value = aws_instance.nginx.private_ip
# }