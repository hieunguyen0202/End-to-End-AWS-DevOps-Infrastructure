variable "region" {
  type = string
}


# Variables from security module

variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnet_names" {
  type = list(string)
}

variable "private_subnet_names" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}




# Variables from security module

variable "public_sg_name" {
  type = string
}

variable "private_sg_name" {
  type = string
}

variable "bastion_sg_name" {
  type = string
}

variable "database_sg_name" {
  type = string
}


# Variables from bastion module


variable "ami_id" {
  type = string
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "key_name" {
  type = string
}

# variable "subnet_id" {
#   description = "Public subnet ID for bastion host"
#   type        = string
# }

# variable "vpc_security_group_ids" {
#   description = "List of security group IDs"
#   type        = list(string)
# }

variable "instance_name" {
  type = string
}

variable "volume_size" {
  default     = 10
  description = "Root volume size in GiB"
  type        = number
}


# Variables from database module


variable "parameter_group_name" {
  type        = string
  description = "Name of the custom parameter group for DocumentDB"
}

variable "parameter_group_family" {
  type        = string
  description = "Parameter group family for DocumentDB, e.g., docdb5.0"
}

variable "subnet_group_name" {
  type        = string
  description = "Name of the subnet group for the DocumentDB cluster"
}

# variable "private_subnet_ids" {
#   type        = list(string)
#   description = "List of private subnet IDs for DocumentDB subnet group"
# }

variable "cluster_identifier" {
  type        = string
  description = "Identifier for the DocumentDB cluster"
}

variable "engine_version" {
  type        = string
  description = "Version of the DocumentDB engine"
}

variable "instance_class" {
  type        = string
  description = "Instance class for DocumentDB instances"
}

variable "instance_count" {
  type        = number
  description = "Number of DocumentDB instances to launch"
}

variable "master_username" {
  type        = string
  description = "Master username for DocumentDB authentication"
}



# variable "security_group_id" {
#   type        = string
#   description = "Security group ID for the DocumentDB cluster"
# }


# Variables from loadbalancer module


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



# Variables from ecs-cluster module



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

# variable "mongo_url" {
#   type        = string
#   description = "MongoDB connection string for backend"
# }

# variable "api_url" {
#   type        = string
#   description = "Public API URL for frontend to communicate with backend"
# }

variable "backend_service_name" {
  type        = string
  description = "Name of the backend ECS service"
}

variable "frontend_service_name" {
  type        = string
  description = "Name of the frontend ECS service"
}

# variable "private_subnet_ids" {
#   type        = list(string)
#   description = "List of private subnet IDs for ECS services"
# }

# variable "security_group_id" {
#   type        = string
#   description = "Security group ID to be associated with ECS services"
# }

# variable "backend_tg_arn" {
#   type        = string
#   description = "ARN of the target group for backend service"
# }

# variable "frontend_tg_arn" {
#   type        = string
#   description = "ARN of the target group for frontend service"
# }