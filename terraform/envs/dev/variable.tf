variable "region" {
  type = string
}

variable "project" {
  description = "The project name to use for unique resource naming"
  default     = "aj3-aws-infra"
  type        = string
}

# network module

variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnet_names" {
  description = "Names for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Names for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "internet_gateway_name" {
  description = "internet_gateway_name"
  type        = string
}

variable "public_rt_name" {
  description = "public_rt_name"
  type        = string
}

variable "nat_gateway_name" {
  description = "nat_gateway_name"
  type        = string
}

variable "private_rt_name" {
  description = "public_rt_name"
  type        = string
}

variable "vpc_bastion_name" {
  description = "Name of the bastion VPC"
  type        = string
}

variable "cidr_bastion_block" {
  description = "CIDR block for the bastion VPC"
  type        = string
}

variable "public_bastion_subnets" {
  description = "List of bastion public subnet CIDR blocks"
  type        = list(string)
}

variable "public_bastion_subnet_name" {
  description = "Names for bastion public subnet"
  type        = string
}

variable "bastion_internet_gateway_name" {
  description = "bastion_internet_gateway_name"
  type        = string
}

variable "bastion_public_rt_name" {
  description = "bastion_public_rt_name"
  type        = string
}

# Security Group Module

variable "nginx_sg_name" {
  type        = string
  description = "Name of the nginx security group"
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

# Bastion module

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
  description = "Name tag for the bastion instance"
  type        = string
}

variable "volume_size" {
  default     = 10
  description = "Root volume size in GiB"
  type        = number
}

variable "nginx_instance_name" {
  description = "Name tag for the nginx instance"
  type        = string
}