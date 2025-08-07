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
  public_nlb_sg_name     = var.public_nlb_sg_name
  nginx_sg_name     = var.nginx_sg_name
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
  nginx_subnet_id           = module.network.aws_nginx_subnet_public_id
  bastion_security_group_id = [module.security.bastion_security_group_id]
  nginx_security_group_id   = [module.security.nginx_security_group_id]
  instance_name             = var.instance_name
  nginx_instance_name       = var.nginx_instance_name
  volume_size               = var.volume_size
  project                   = var.project
}


module "ecs-cluster" {
  source                        = "../../modules/ecs-cluster"
  ecr_repo_name                 = var.ecr_repo_name
  aws_ecs_cluster_name          = var.aws_ecs_cluster_name
  aws_ecs_task_definition_name  = var.aws_ecs_task_definition_name
  backend_task_family           = var.backend_task_family
  backend_service_name          = var.backend_service_name
  backend_image_tag             = var.backend_image_tag
  container_port                = var.container_port
  host_port                     = var.host_port
  private_subnet_ids            = module.network.aws_app_subnet_private_ids
  app_security_group_id         = module.security.app_security_group_id
  aws_ecs_service               = var.aws_ecs_service
  project                       = var.project
  aws_region                    = var.region
  vpc2_id                        = module.network.vpc2_id
}