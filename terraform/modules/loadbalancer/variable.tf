variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group to attach to the ALB"
  type        = string
}

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
}

variable "frontend_tg_name" {
  description = "Name of the frontend target group"
  type        = string
}

variable "frontend_port" {
  description = "Frontend target group port"
  type        = number
  default     = 3000
}

variable "backend_tg_name" {
  description = "Name of the backend target group"
  type        = string
}

variable "backend_port" {
  description = "Backend target group port"
  type        = number
  default     = 8080
}