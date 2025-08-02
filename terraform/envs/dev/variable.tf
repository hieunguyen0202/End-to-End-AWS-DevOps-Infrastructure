variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}