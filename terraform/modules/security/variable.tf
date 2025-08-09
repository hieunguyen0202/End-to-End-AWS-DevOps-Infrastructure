variable "vpc2_id" {
  description = "The ID of the main VPC"
  type        = string
}

variable "vpc1_id" {
  description = "The ID of the bastion VPC"
  type        = string
}


variable "project" {
  description = "The project name to use for unique resource naming"
  default     = "aj3-aws-infra"
  type        = string
}

variable "public_alb_sg_name" {
  type        = string
  description = "Name of Public ALB Security Group"
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