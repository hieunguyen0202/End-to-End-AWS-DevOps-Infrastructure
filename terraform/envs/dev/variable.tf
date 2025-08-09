variable "region" {
  type = string
}

variable "project" {
  description = "The project name to use for unique resource naming"
  default     = "aj3-aws-infra"
  type        = string
}

# network module

variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnet_names" {
  description = "Names for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Names for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "internet_gateway_name" {
  description = "internet_gateway_name"
  type        = string
}

variable "public_rt_name" {
  description = "public_rt_name"
  type        = string
}

variable "nat_gateway_name" {
  description = "nat_gateway_name"
  type        = string
}

variable "private_rt_name" {
  description = "public_rt_name"
  type        = string
}

variable "vpc_bastion_name" {
  description = "Name of the bastion VPC"
  type        = string
}

variable "cidr_bastion_block" {
  description = "CIDR block for the bastion VPC"
  type        = string
}

variable "public_bastion_subnets" {
  description = "List of bastion public subnet CIDR blocks"
  type        = list(string)
}

variable "public_bastion_subnet_name" {
  description = "Names for bastion public subnet"
  type        = string
}

variable "bastion_internet_gateway_name" {
  description = "bastion_internet_gateway_name"
  type        = string
}

variable "bastion_public_rt_name" {
  description = "bastion_public_rt_name"
  type        = string
}

# Security Group Module

variable "public_alb_sg_name" {
  type        = string
  description = "Name of Public NLB Security Group"
}


variable "app_sg_name" {
  type        = string
  description = "Name of the app security group"
}

variable "bastion_sg_name" {
  type        = string
  description = "Name of the bastion security group"
}

variable "database_sg_name" {
  type        = string
  description = "Name of the database security group"
}

# Bastion module

variable "ami_id" {
  description = "AMI ID for Ubuntu Server"
  type        = string
}

variable "instance_type" {
  default     = "t3.small"
  description = "EC2 instance type"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the bastion instance"
  type        = string
}

variable "volume_size" {
  default     = 10
  description = "Root volume size in GiB"
  type        = number
}

# variable "nginx_instance_name" {
#   description = "Name tag for the nginx instance"
#   type        = string
# }


# ECS module

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


variable "aws_ecs_service" {
  type        = string
  description = "Name of the ECS service"
}


# Database

variable "db_subnet_group_name" {
  default = "aws-infra-03-rds-sub-grp"
}

variable "db_parameter_group_name" {
  default = "aws-infra-03-para-grp"
}

variable "db_identifier" {
  default = "aws-infra-03-rds-mysql-db"
}

variable "db_name" {
  default = "mydatabase"
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