provider "aws" {
  region = var.region
}

module "network" {
  source               = "../../modules/network"
  vpc_name             = var.vpc_name
  cidr_block           = var.cidr_block
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  public_subnet_names  = var.public_subnet_names
  private_subnet_names = var.private_subnet_names
  availability_zones   = var.availability_zones
  region               = var.region
}




