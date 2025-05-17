variable "app_name" {
  description = "Name of the Elastic Beanstalk application"
  type        = string
}

variable "env_name" {
  description = "Name of the Elastic Beanstalk environment"
  type        = string
}

variable "project_tag" {
  description = "Project tag to associate with resources"
  type        = string
}

variable "ec2_role_name" {
  description = "IAM role name for EC2 instances"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name for Beanstalk EC2s"
  type        = string
}

variable "service_role_name" {
  description = "Service role for Beanstalk environment"
  type        = string
}

variable "ec2_key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy Beanstalk environment"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for EC2 instances"
  type        = list(string)
}

variable "ec2_security_groups" {
  description = "Security group IDs to assign to EC2 instances in the Beanstalk environment"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for ELB"
  type        = list(string)
}

variable "elb_security_group" {
  description = "Security group to attach to ELB"
  type        = string
}

variable "ssl_certificate_arn" {
  description = "SSL certificate ARN for HTTPS listener"
  type        = string
}
