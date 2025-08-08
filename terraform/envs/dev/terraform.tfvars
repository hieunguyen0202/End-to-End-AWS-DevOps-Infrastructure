region = "ap-southeast-1"
project = "aj3-aws-infra-dev-project"

# Network Module
vpc_name = "aj3-aws-infra-vpc2-dev"
cidr_block = "10.0.0.0/16"
availability_zones = ["ap-southeast-1a", "ap-southeast-1c"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.10.0/24", "10.0.20.0/24"]
public_subnet_names  = ["aj3-aws-infra-vpc2-pub1-dev", "aj3-aws-infra-vpc2-pub2-dev"]
private_subnet_names = ["aj3-aws-infra-vpc2-pri1-dev", "aj3-aws-infra-vpc2-pri2-dev"]
internet_gateway_name = "aj3-aws-infra-vpc2-igw-dev"
public_rt_name = "aj3-aws-infra-vpc2-rtb-pub-dev"
private_rt_name = "aj3-aws-infra-vpc2-rtb-pri-dev"
nat_gateway_name = "aj3-aws-infra-vpc2-pub1-nat-dev"
vpc_bastion_name = "aj3-aws-infra-vpc1-dev"
cidr_bastion_block = "10.10.0.0/16"
public_bastion_subnets = ["10.10.0.0/24"]
public_bastion_subnet_name = "aj3-aws-infra-vpc1-pub1-dev"
bastion_internet_gateway_name = "aj3-aws-infra-vpc1-igw-dev"
bastion_public_rt_name = "aj3-aws-infra-vpc1-rtb-dev"


# SG module
public_nlb_sg_name   = "aj3-aws-infra-vpc2-public-nlb-sg-dev"
nginx_sg_name   = "aj3-aws-infra-vpc2-nginx-sg-dev"
app_sg_name  = "aj3-aws-infra-vpc2-app-sg-dev"
bastion_sg_name  = "aj3-aws-infra-vpc1-bastion-sg-dev"
database_sg_name = "aj3-aws-infra-vpc2-db-sg-dev"

# Bastion module
ami_id        = "ami-0c1907b6d738188e5"
instance_type = "t3.small"
key_name      = "aj3-aws-infra-vpc1-key-dev"
instance_name = "aj3-aws-infra-vpc1-bastion-vm-dev"
nginx_instance_name = "aj3-aws-infra-vpc2-nginx-vm-dev"
volume_size   = 10

# ECS module
ecr_moai_repo_name            = "aj3-aws-infra-moai-ecr-repo-dev"
ecr_aegis_repo_name           = "aj3-aws-infra-aegis-ecr-repo-dev"
ecr_valkey_repo_name          = "aj3-aws-infra-val-ecr-repo-dev"
aws_ecs_cluster_name          = "aj3-aws-infra-ecs-cluster-dev"
aws_ecs_task_definition_name  = "aj3-aws-infra-ecs-task-def-dev"
moai_image_tag                = "0.0.0"
aegis_image_tag               = "0.0.0"
valkey_image_tag              = "0.0.0"
container_port                = 8080
host_port                     = 8080
aws_ecs_service               = "aj3-aws-infra-ecs-service-dev"


# Database module
db_subnet_group_name        = "aj3-aws-infra-rds-sub-grp-dev"
db_parameter_group_name     = "aj3-aws-infra-rds-para-grp-dev"
db_identifier               = "aj3-aws-infra-rds-mysql-db-dev"
db_name                     = "moai_auth"
db_username                 = "admin"
db_password                 = "StrongPassw0rd"