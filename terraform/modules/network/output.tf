output "vpc2_id" {
  value = aws_vpc.main.id
}

output "vpc1_id" {
  value = aws_vpc.bastion.id
}

output "aws_bastion_subnet_public_id" {
  value = aws_subnet.bastion_public.id
}

output "aws_nginx_subnet_public_id" {
  value = aws_subnet.private[0].id
}

output "aws_app_subnet_private_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "aws_subnet_public_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}