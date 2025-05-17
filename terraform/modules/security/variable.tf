variable "vpc_id" {
  description = "The ID of the VPC where SGs will be created"
  type        = string
}

variable "public_sg_name" {
  type        = string
  description = "Name of the public security group"
}

variable "private_sg_name" {
  type        = string
  description = "Name of the private security group"
}

variable "bastion_sg_name" {
  type        = string
  description = "Name of the bastion security group"
}

variable "database_sg_name" {
  type        = string
  description = "Name of the database security group"
}