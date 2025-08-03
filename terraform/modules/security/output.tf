output "nginx_security_group_id" {
  value = aws_security_group.nginx_sg.id
}
output "app_security_group_id" {
  value = aws_security_group.app_sg.id
}
output "database_security_group_id" {
  value = aws_security_group.database_sg.id
}
output "bastion_security_group_id" {
  value = aws_security_group.bastion_sg.id
}


