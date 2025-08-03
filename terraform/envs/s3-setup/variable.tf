variable "region" {
  type = string
}

variable "project" {
  description = "The project name to use for unique resource naming"
  default     = "aj3-aws-infra"
  type        = string
}

variable "principal_arns" {
  description = "A list of principal arns allowed to assume the IAM role"
  default     = null
  type        = list(string)
}



variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}