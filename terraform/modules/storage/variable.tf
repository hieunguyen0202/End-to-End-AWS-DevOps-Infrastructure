variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-lock-table"
}

variable "environment" {
  description = "Environment (dev, prod, etc.)"
  type        = string
}
