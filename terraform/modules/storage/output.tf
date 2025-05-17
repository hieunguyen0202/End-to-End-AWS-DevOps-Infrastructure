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


output "elasticache_endpoint" {
  description = "ElastiCache Memcached endpoint"
  value       = aws_elasticache_cluster.memcached.cache_nodes[0].address
}

output "elasticache_port" {
  description = "ElastiCache Memcached port"
  value       = aws_elasticache_cluster.memcached.port
}
