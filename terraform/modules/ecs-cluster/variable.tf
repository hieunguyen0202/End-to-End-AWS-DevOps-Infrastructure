variable "project" {
  description = "The project name to use for unique resource naming"
  type        = string
}

variable "ecr_tomcat_repo_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "ecr_memcached_repo_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "ecr_rabbitmq_repo_name" {
  type        = string
  description = "Name of the ECR repository"
}


variable "aws_ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "aws_ecs_task_definition_name" {
  type        = string
  description = "Name of the ecs task definition"
}

variable "db_username" {
  type        = string
  description = "Username for RDS database"
}

variable "db_password" {
  type        = string
  description = "Password for RDS database"
  sensitive   = true
}

variable "rds_endpoint" {
  type        = string
  description = "RDS database endpoint"
}

variable "db_mode" {
  description = "aurora or mysql"
  type        = string
  default     = "aurora"
}


variable "tomcat_image_tag" {
  type        = string
  description = "ECR image tag to deploy"
  default     = "latest"
}

variable "memcached_image_tag" {
  type        = string
  description = "ECR image tag to deploy"
  default     = "latest"
}

variable "rabbitmq_image_tag" {
  type        = string
  description = "ECR image tag to deploy"
  default     = "latest"
}


variable "container_port" {
  type        = number
  description = "Port the container listens on"
  default     = 80
}

variable "host_port" {
  type        = number
  description = "Port mapped on the host (for awsvpc, same as container port)"
  default     = 80
}


variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-1"
}


variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for ECS services"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "app_security_group_id" {
  type        = string
  description = "Security group ID to be associated with ECS services"
}

# variable "efs_sg_id" {
#   type        = string
#   description = "Security group ID to be associated with aws_efs_mount_target"
# }

variable "alb_security_group_id" {
  description = "Security group ID to attach to the Application Load Balancer"
  type        = string
}

variable "aws_ecs_service" {
  type        = string
  description = "Name of the ECS service"
}

variable "vpc2_id" {
  description = "The ID of the main VPC"
  type        = string
}
