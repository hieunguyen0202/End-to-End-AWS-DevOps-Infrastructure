region = "ap-southeast-1"

vpc_name   = "aws-infra-03-vpc"
cidr_block = "10.0.0.0/16"

availability_zones = ["ap-southeast-1a", "ap-southeast-1c"]

public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.10.0/24", "10.0.20.0/24"]

public_subnet_names  = ["aws-infra-03-public-subnet-1", "aws-infra-03-public-subnet-2"]
private_subnet_names = ["aws-infra-03-private-subnet-1", "aws-infra-03-private-subnet-2"]

public_sg_name   = "aws-infra-03-public-sg"
private_sg_name  = "aws-infra-03-private-sg"
bastion_sg_name  = "aws-infra-03-bastion-sg"
database_sg_name = "aws-infra-03-database-sg"



