terraform {
  backend "s3" {
    bucket = "aj3-aws-infra-terraform-state-uat"
    key    = "dev/terraform.tfstate"
    region = "ap-southeast-1"
  
  }
}