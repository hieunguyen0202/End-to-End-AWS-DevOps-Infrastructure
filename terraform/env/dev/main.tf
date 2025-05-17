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

module "security" {
  source           = "../../modules/security"
  vpc_id           = module.network.vpc_id
  public_sg_name   = var.public_sg_name
  private_sg_name  = var.private_sg_name
  bastion_sg_name  = var.bastion_sg_name
  database_sg_name = var.database_sg_name
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = module.security.rds_password_secret_name
}

module "storage" {
  source             = "../../modules/storage"
  availability_zones = var.availability_zones
  subnet_ids         = module.network.aws_subnet_private_id[1]
  security_group_id  = module.security.database_security_group_id
  db_password        = data.aws_secretsmanager_secret_version.db_password.secret_string

}




