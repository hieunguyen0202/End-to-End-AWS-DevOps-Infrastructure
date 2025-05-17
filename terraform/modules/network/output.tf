output "vpc_id" {
  value = aws_vpc.main.id
}

output "aws_subnet_public_id" {
  value = [for subnet in aws_subnet.public : subnet.id]
}


output "aws_subnet_private_id" {
  value = [for subnet in aws_subnet.private : subnet.id]
}