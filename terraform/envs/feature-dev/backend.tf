terraform {
  backend "s3" {
    bucket = "aj3-aws-infra-project-s3-backend"
    key    = "featuredev/terraform.tfstate"
    region = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "aj3-aws-infra-project-s3-backend"
  }
}