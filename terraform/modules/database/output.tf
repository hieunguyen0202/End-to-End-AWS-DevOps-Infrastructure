output "db_endpoint" {
  description = "Database writer endpoint (Aurora cluster or MySQL primary)"
  value = (
    var.db_mode == "aurora"
      ? aws_rds_cluster.aurora[0].endpoint
      : aws_db_instance.mysql_primary[0].endpoint
  )
}

output "db_reader_endpoint" {
  description = "Database reader endpoint (Aurora reader or MySQL replica)"
  value = (
    var.db_mode == "aurora"
      ? aws_rds_cluster.aurora[0].reader_endpoint
      : (length(aws_db_instance.mysql_replica) > 0 ? aws_db_instance.mysql_replica[0].endpoint : "")
  )
}

output "db_username" {
  description = "Database master username"
  value = (
    var.db_mode == "aurora"
      ? aws_rds_cluster.aurora[0].master_username
      : aws_db_instance.mysql_primary[0].username
  )
}

output "db_port" {
  description = "Database port"
  value = (
    var.db_mode == "aurora"
      ? aws_rds_cluster.aurora[0].port
      : aws_db_instance.mysql_primary[0].port
  )
}
