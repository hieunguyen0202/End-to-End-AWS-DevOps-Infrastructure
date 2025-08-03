output "vpc2_id" {
  value = aws_vpc.main.id
}

output "vpc1_id" {
  value = aws_vpc.bastion.id
}