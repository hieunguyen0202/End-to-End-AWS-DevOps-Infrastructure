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

ami_id        = "ami-0c1907b6d738188e5"
instance_type = "t3.small"
key_name      = "aws-infra-01-key"
instance_name = "aws-infra-01-bastion-vm"
volume_size   = 10


app_name        = "aws-infra-03-beanstalk-application"
env_name        = "aws-infra-03-beanstalk-environment-dev"    
project_tag     = "AWS-Infra-03-RDSCacheMQBeanstalkInfra" 
ec2_role_name     = "aws-infra-03-beanstalk-role"
instance_profile_name     = "aws-infra-03-beanstalk-role" 
service_role_name     = "aws-infra-03-beanstalk-service-role" 
ssl_certificate_arn     = "arn:aws:acm:us-east-1:143735903781:certificate/647c393a-9169-4517-bb26-9ab713dda521" 



