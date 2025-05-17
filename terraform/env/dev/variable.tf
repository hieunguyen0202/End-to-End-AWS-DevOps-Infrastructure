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

