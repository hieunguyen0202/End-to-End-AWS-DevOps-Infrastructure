variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "task_exec_role_name" {
  type        = string
  description = "Name of the ECS task execution role"
}


variable "backend_task_family" {
  type        = string
  description = "Family name for the backend ECS task definition"
}

variable "frontend_task_family" {
  type        = string
  description = "Family name for the frontend ECS task definition"
}

variable "backend_image_uri" {
  type        = string
  description = "ECR Image URI for the backend container"
}

variable "frontend_image_uri" {
  type        = string
  description = "ECR Image URI for the frontend container"
}

variable "mongo_url" {
  type        = string
  description = "MongoDB connection string for backend"
}

variable "api_url" {
  type        = string
  description = "Public API URL for frontend to communicate with backend"
}

variable "backend_service_name" {
  type        = string
  description = "Name of the backend ECS service"
}

variable "frontend_service_name" {
  type        = string
  description = "Name of the frontend ECS service"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for ECS services"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID to be associated with ECS services"
}

variable "backend_tg_arn" {
  type        = string
  description = "ARN of the target group for backend service"
}

variable "frontend_tg_arn" {
  type        = string
  description = "ARN of the target group for frontend service"
}
