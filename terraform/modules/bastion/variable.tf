variable "project" {
  description = "The project name to use for unique resource naming"
  type        = string
}

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

variable "subnet_id" {
  description = "Public subnet ID for bastion host"
  type        = string
}

variable "bastion_security_group_id" {
  description = "List of security group IDs"
  type        = list(string)
}


variable "nginx_security_group_id" {
  description = "Security Group ID for nginx server"
  type        = list(string)
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

variable "nginx_subnet_id" {
  description = "Public subnet ID for nginx"
  type        = string
}