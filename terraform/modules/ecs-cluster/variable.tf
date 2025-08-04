variable "project" {
  description = "The project name to use for unique resource naming"
  type        = string
}

variable "ecr_repo_name" {
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


variable "backend_task_family" {
  type        = string
  description = "Family name for the backend ECS task definition"
}


variable "backend_service_name" {
  type        = string
  description = "Name of the backend ECS service"
}


variable "backend_image_tag" {
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



variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for ECS services"
}

variable "app_security_group_id" {
  type        = string
  description = "Security group ID to be associated with ECS services"
}

variable "aws_ecs_service" {
  type        = string
  description = "Name of the ECS service"
}