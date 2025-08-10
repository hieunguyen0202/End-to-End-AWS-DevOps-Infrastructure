provider "aws" {
  region = var.region
}


resource "aws_resourcegroups_group" "resourcegroups_group" {
  name = "${var.project}-resource-group"

  resource_query {
    query = <<-JSON
      {
        "ResourceTypeFilters": [
          "AWS::AllSupported"
        ],
        "TagFilters": [
          {
            "Key": "project",
            "Values": ["${var.project}"]
          }
        ]
      }
    JSON
  }
}

module "network" {
  source                        = "../../modules/network"
  vpc_name                      = var.vpc_name
  cidr_block                    = var.cidr_block
  project                       = var.project
  public_subnets                = var.public_subnets
  private_subnets               = var.private_subnets
  public_subnet_names           = var.public_subnet_names
  private_subnet_names          = var.private_subnet_names
  availability_zones            = var.availability_zones
  internet_gateway_name         = var.internet_gateway_name
  public_rt_name                = var.public_rt_name
  private_rt_name               = var.private_rt_name
  nat_gateway_name              = var.nat_gateway_name
  vpc_bastion_name              = var.vpc_bastion_name
  cidr_bastion_block            = var.cidr_bastion_block
  public_bastion_subnets        = var.public_bastion_subnets
  public_bastion_subnet_name    = var.public_bastion_subnet_name
  bastion_internet_gateway_name = var.bastion_internet_gateway_name
  bastion_public_rt_name        = var.bastion_public_rt_name
}

module "security" {
  source            = "../../modules/security"
  vpc1_id           = module.network.vpc1_id
  vpc2_id           = module.network.vpc2_id
  public_alb_sg_name     = var.public_alb_sg_name
  app_sg_name       = var.app_sg_name
  bastion_sg_name   = var.bastion_sg_name
  database_sg_name  = var.database_sg_name
  project           = var.project
}

module "bastion" {
  source                    = "../../modules/bastion"
  ami_id                    = var.ami_id
  instance_type             = var.instance_type
  key_name                  = var.key_name
  subnet_id                 = module.network.aws_bastion_subnet_public_id
  # nginx_subnet_id           = module.network.aws_nginx_subnet_public_id
  bastion_security_group_id = [module.security.bastion_security_group_id]
  instance_name             = var.instance_name
  # nginx_instance_name       = var.nginx_instance_name
  volume_size               = var.volume_size
  project                   = var.project
}


module "ecs-cluster" {
  source                        = "../../modules/ecs-cluster"
  ecr_tomcat_repo_name            = var.ecr_tomcat_repo_name
  ecr_memcached_repo_name           = var.ecr_memcached_repo_name
  ecr_rabbitmq_repo_name          = var.ecr_rabbitmq_repo_name
  aws_ecs_cluster_name          = var.aws_ecs_cluster_name
  aws_ecs_task_definition_name  = var.aws_ecs_task_definition_name
  tomcat_image_tag                = var.tomcat_image_tag
  memcached_image_tag               = var.memcached_image_tag
  rabbitmq_image_tag              = var.rabbitmq_image_tag
  container_port                = var.container_port
  host_port                     = var.host_port
  private_subnet_ids            = module.network.aws_app_subnet_private_ids
  app_security_group_id         = module.security.app_security_group_id
  aws_ecs_service               = var.aws_ecs_service
  db_mode                       = var.db_mode
  project                       = var.project
  aws_region                    = var.region
  vpc2_id                       = module.network.vpc2_id
  db_username                   = var.db_username
  db_password                   = var.db_password
  rds_endpoint                  = module.database.db_endpoint
  alb_security_group_id         = module.security.alb_security_group_id
  public_subnet_ids             = module.network.aws_subnet_public_ids
}


module "database" {
  source                        = "../../modules/database"
  db_subnet_group_name          = var.db_subnet_group_name
  db_parameter_group_name       = var.db_parameter_group_name
  db_identifier                 = var.db_identifier
  db_name                       = var.db_name
  db_username                   = var.db_username
  db_password                   = var.db_password
  security_group_id             = module.security.database_security_group_id
  availability_zones            = var.availability_zones
  subnet_ids                    = module.network.aws_app_subnet_private_ids
  project                       = var.project
  db_mode                       = var.db_mode
  enable_snapshot               = var.enable_snapshot
  dr_region                     = var.dr_region
}