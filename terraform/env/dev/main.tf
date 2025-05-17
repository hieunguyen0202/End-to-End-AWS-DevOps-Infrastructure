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


module "storage" {
  source                        = "../../modules/storage"
  availability_zones            = var.availability_zones
  subnet_ids                    = module.network.aws_subnet_private_id
  security_group_id             = module.security.database_security_group_id
  db_password                   = module.security.rds_password_secret_string
  rabbitmq_password             = module.security.rmq_password_secret_string
  rabbitmq_subnet_id            = module.network.aws_subnet_private_id[0] 
}

module "bastion" {
  source                 = "../../modules/bastion"
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = module.network.aws_subnet_public_id[0]
  vpc_security_group_ids = [module.security.bastion_security_group_id]
  instance_name          = var.instance_name
  volume_size            = var.volume_size
}





