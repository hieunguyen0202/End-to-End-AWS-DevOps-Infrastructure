terraform {
  backend "s3" {
    bucket = "aws-infra-03-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "ap-southeast-1"
  
  }
}

