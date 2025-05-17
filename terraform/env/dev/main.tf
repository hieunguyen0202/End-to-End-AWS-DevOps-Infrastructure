provider "aws" {
  region = var.region
}


module "network" {
  source               = "../modules/network"
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
  source           = "../modules/security"
  vpc_id           = module.network.vpc_id
  public_sg_name   = var.public_sg_name
  private_sg_name  = var.private_sg_name
  bastion_sg_name  = var.bastion_sg_name
  database_sg_name = var.database_sg_name
}


module "bastion" {
  source                 = "../modules/bastion"
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = module.network.aws_subnet_public_id[0]
  vpc_security_group_ids = [module.security.bastion_security_group_id]
  instance_name          = var.instance_name
  volume_size            = var.volume_size
}

module "database" {
  source = "../modules/database"

  parameter_group_name   = var.parameter_group_name
  parameter_group_family = var.parameter_group_family
  subnet_group_name      = var.subnet_group_name
  private_subnet_ids     = module.network.aws_subnet_private_id
  cluster_identifier     = var.cluster_identifier
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  instance_count         = var.instance_count
  master_username        = var.master_username
  security_group_id      = module.security.database_security_group_id
}


module "loadbalancer" {
  source            = "../modules/loadbalancer"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.aws_subnet_public_id
  security_group_id = module.security.public_security_group_id

  alb_name         = var.alb_name
  frontend_tg_name = var.frontend_tg_name
  frontend_port    = var.frontend_port
  backend_tg_name  = var.backend_tg_name
  backend_port     = var.backend_port
}


module "ecs_cluster" {
  source = "../modules/ecs-cluster"

  ecs_cluster_name    = var.ecs_cluster_name
  task_exec_role_name = var.task_exec_role_name

  backend_task_family  = var.backend_task_family
  frontend_task_family = var.frontend_task_family
  backend_image_uri    = var.backend_image_uri
  frontend_image_uri   = var.frontend_image_uri
  mongo_url            = module.database.mongodb_connection_string_secret_arn
  api_url              = "http://${module.loadbalancer.alb_dns}:80"

  backend_service_name  = var.backend_service_name
  frontend_service_name = var.frontend_service_name

  private_subnet_ids = module.network.aws_subnet_private_id
  security_group_id  = module.security.private_security_group_id
  backend_tg_arn     = module.loadbalancer.backend_target_group_arn
  frontend_tg_arn    = module.loadbalancer.frontend_target_group_arn
}
