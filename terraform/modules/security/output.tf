output "public_security_group_id" {
  value = aws_security_group.public_sg.id
}
output "private_security_group_id" {
  value = aws_security_group.private_sg.id
}
output "database_security_group_id" {
  value = aws_security_group.database_sg.id
}
output "bastion_security_group_id" {
  value = aws_security_group.bastion_sg.id
}