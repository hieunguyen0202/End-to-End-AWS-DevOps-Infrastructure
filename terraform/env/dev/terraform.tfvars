vpc_name   = "aws-infra-01-vpc"
cidr_block = "10.0.0.0/16"
region     = "ap-southeast-1"

availability_zones = ["ap-southeast-1a", "ap-southeast-1c"]

public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.10.0/24", "10.0.20.0/24"]

public_subnet_names  = ["aws-infra-01-public-subnet-1", "aws-infra-01-public-subnet-2"]
private_subnet_names = ["aws-infra-01-private-subnet-1", "aws-infra-01-private-subnet-2"]



public_sg_name   = "aws-infra-01-public-sg"
private_sg_name  = "aws-infra-01-private-sg"
bastion_sg_name  = "aws-infra-01-bastion-sg"
database_sg_name = "aws-infra-01-database-sg"


ami_id        = "ami-0c1907b6d738188e5"
instance_type = "t3.small"
key_name      = "aws-infra-01-key"
instance_name = "aws-infra-01-bastion-vm"
volume_size   = 10

parameter_group_name   = "aws-infra-01-param-grp"
parameter_group_family = "docdb5.0"
subnet_group_name      = "aws-infra-01-subnet-grp"
cluster_identifier     = "aws-infra-01-mongodb-cluster"
engine_version         = "5.0.0"
instance_class         = "db.t3.medium"
instance_count         = 1
master_username        = "adminmongodb"



alb_name         = "aws-infra-01-alb"
frontend_tg_name = "aws-infra-01-frontend-tg"
frontend_port    = 3000
backend_tg_name  = "aws-infra-01-backend-tg"
backend_port     = 8080


ecs_cluster_name      = "aws-infra-01-ecs-cluster"
task_exec_role_name   = "aws-infra-01-task-exec-role"
backend_task_family   = "aws-infra-01-task-definition-be"
frontend_task_family  = "aws-infra-01-task-definition-fe"
backend_service_name  = "aws-infra-01-service-be"
frontend_service_name = "aws-infra-01-service-fe"
backend_image_uri     = "143735903781.dkr.ecr.ap-southeast-1.amazonaws.com/aws-infra-01-ecr-be-repo:latest"
frontend_image_uri    = "143735903781.dkr.ecr.ap-southeast-1.amazonaws.com/aws-infra-01-ecr-fe-repo:latest"

