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
  default     = "aws-infra-01-bastion-vm"
  description = "Name tag for the bastion instance"
  type        = string
}

variable "volume_size" {
  default     = 10
  description = "Root volume size in GiB"
  type        = number
}
