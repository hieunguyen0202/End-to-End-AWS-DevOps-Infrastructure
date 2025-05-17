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

output "rds_password_secret_arn" {
  value       = aws_secretsmanager_secret.rds_password.arn
  description = "ARN of the RDS password secret"
}

output "rds_password_secret_name" {
  value       = aws_secretsmanager_secret.rds_password.name
  description = "Name of the RDS password secret"
}

output "rds_password_secret_string" {
  value = aws_secretsmanager_secret_version.rds_password_version.secret_string
}