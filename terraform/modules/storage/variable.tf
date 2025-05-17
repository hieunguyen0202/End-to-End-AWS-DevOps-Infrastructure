variable "db_identifier" {
  default = "aws-infra-03-rds-mysql-db"
}

variable "db_name" {
  default = "mydatabase"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  description = "Password for RDS"
  sensitive   = true
}

variable "db_subnet_group_name" {
  default = "aws-infra-03-rds-sub-grp"
}

variable "db_parameter_group_name" {
  default = "aws-infra-03-para-grp"
}

variable "subnet_ids" {
  type = list(string)
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1c"]
}

variable "security_group_id" {
  type        = string
  description = "Existing security group ID for the RDS instance"
}

// Memcached Elasticache cluster

variable "elasticache_subnet_group_name" {
  description = "Name for the ElastiCache subnet group"
  default     = "aws-infra-03-elasticecache-sub-grp"
  type        = string
}

variable "elasticache_parameter_group_name" {
  description = "Name for the ElastiCache parameter group"
  type        = string
  default     = "aws-infra-03-elasticecache-para-grp"
}

variable "elasticache_cluster_id" {
  description = "Cluster ID (name) of the ElastiCache cluster"
  type        = string
  default     = "aws-infra-03-elasticecache-svc"
}

variable "elasticache_engine_version" {
  description = "Engine version of ElastiCache Memcached"
  type        = string
  default     = "1.6.17"
}

variable "elasticache_node_type" {
  description = "Node type for ElastiCache"
  type        = string
  default     = "cache.t2.micro"
}

variable "elasticache_node_count" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "elasticache_port" {
  description = "Port for ElastiCache"
  type        = number
  default     = 11211
}

variable "project_tag" {
  description = "Project tag for resources"
  type        = string
  default     = "AWS-Infra-03-RDSCacheMQBeanstalkInfra"
}

// Amamzon MQ
variable "rabbitmq_broker_name" {
  description = "Name of the RabbitMQ broker"
  type        = string
  default     = "aws-infra-03-rmq"
}

variable "rabbitmq_instance_type" {
  description = "Instance type for RabbitMQ broker"
  type        = string
  default     = "mq.t3.micro"
}

variable "rabbitmq_username" {
  description = "Username for RabbitMQ"
  type        = string
  default     = "rabbit"
}

variable "rabbitmq_password_secret_name" {
  description = "Name of the AWS Secrets Manager secret storing RabbitMQ password"
  type        = string
}

variable "rabbitmq_engine_version" {
  description = "Version of RabbitMQ engine"
  type        = string
  default     = "3.10.20"
}

variable "rabbitmq_subnet_id" {
  description = "Subnet ID for RabbitMQ broker"
  type        = string
}

