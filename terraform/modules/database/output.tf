output "mongodb_endpoint"{
  value = aws_docdb_cluster.cluster.endpoint
}
output "mongodb_password_secret_arn" {
  value = aws_secretsmanager_secret.mongodb_password_secret.arn
}
output "mongodb_connection_string_secret_arn" {
  value = aws_secretsmanager_secret_version.mongodb_connection_string_version.secret_string
}