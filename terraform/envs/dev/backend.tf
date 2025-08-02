terraform {
  backend "s3" {
    bucket = "aj3-aws-infra-terraform-state-dev"
    key    = "dev/terraform.tfstate"
    region = "ap-southeast-1"
  
  }
}