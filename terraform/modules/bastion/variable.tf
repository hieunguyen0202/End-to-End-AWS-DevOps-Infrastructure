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

variable "vpc_security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
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
