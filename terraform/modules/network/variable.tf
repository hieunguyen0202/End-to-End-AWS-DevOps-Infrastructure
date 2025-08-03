variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "project" {
  description = "The project name to use for unique resource naming"
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