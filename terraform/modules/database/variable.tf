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

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for DocumentDB subnet group"
}

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

# variable "master_password" {
#   type        = string
#   description = "Master password for DocumentDB authentication"
#   sensitive   = true
# }

variable "security_group_id" {
  type        = string
  description = "Security group ID for the DocumentDB cluster"
}
