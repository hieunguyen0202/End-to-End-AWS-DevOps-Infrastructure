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