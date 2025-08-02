provider "aws" {
  region = var.region
}

module "network" {
  source               = "../../modules/network"
  vpc_name             = var.vpc_name
}