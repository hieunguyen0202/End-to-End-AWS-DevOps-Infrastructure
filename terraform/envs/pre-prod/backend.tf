terraform {
  backend "s3" {
    bucket = "aj3-aws-infra-terraform-state"
    key    = "pre-prod/terraform.tfstate"
    region = "ap-southeast-1"
  }
}