variable "project" {
  description = "The project name to use for unique resource naming"
  type        = string
}


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
