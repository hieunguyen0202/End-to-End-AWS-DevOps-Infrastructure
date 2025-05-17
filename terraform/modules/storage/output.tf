output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.rds.endpoint
}

output "rds_username" {
  description = "RDS master username"
  value       = aws_db_instance.rds.username
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.rds.port
}
