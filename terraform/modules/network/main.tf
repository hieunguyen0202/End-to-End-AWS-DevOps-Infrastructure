locals {
  tags = {
    project     = var.project
  }
}

resource "aws_vpc" "main" {
    cidr_block           = var.cidr_block
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = merge(
      local.tags,
      {
        Name = var.vpc_name
      }
  )
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
      local.tags,
      {
        Name = var.public_subnet_names[count.index]
      }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
      local.tags,
      {
        Name = var.private_subnet_names[count.index]
      }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
      local.tags,
      {
        Name = "${var.internet_gateway_name}"
      }
  )
}


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
      local.tags,
      {
        Name = "${var.public_rt_name}"
      }
  )

}


# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Allocate an Elastic IP for NAT Gateway
resource "aws_eip" "nat" {

  tags = merge(
      local.tags,
      {
        Name = "${var.nat_gateway_name}-eip"
      }
  )
}


# Create NAT Gateway in public subnet 1
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(
      local.tags,
      {
        Name = "${var.nat_gateway_name}"
      }
  )
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(
      local.tags,
      {
        Name = "${var.private_rt_name}"
      }
  )
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Bastion Network Module (VPC1)

resource "aws_vpc" "bastion" {
  cidr_block           = var.cidr_bastion_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.tags,
    {
      Name = var.vpc_bastion_name
    }
  )
}

resource "aws_subnet" "bastion_public" {
  vpc_id                  = aws_vpc.bastion.id
  cidr_block              = var.public_bastion_subnets[0]                  # Only 1 public subnet
  availability_zone       = var.availability_zones[0]              # Only 1 AZ
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name = var.public_bastion_subnet_name
    }
  )
}


# Internet Gateway
resource "aws_internet_gateway" "bastion_igw" {
  vpc_id = aws_vpc.bastion.id

  tags = merge(
      local.tags,
      {
        Name = "${var.bastion_internet_gateway_name}"
      }
  )
}


# Public Route Table
resource "aws_route_table" "bastion_public" {
  vpc_id = aws_vpc.bastion.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bastion_igw.id
  }

  tags = merge(
      local.tags,
      {
        Name = "${var.bastion_public_rt_name}"
      }
  )

}


# Associate public subnets with the public route table
resource "aws_route_table_association" "bastion_public" {
  subnet_id      = aws_subnet.bastion_public.id
  route_table_id = aws_route_table.bastion_public.id
}


# Create VPC Peering Connection

resource "aws_vpc_peering_connection" "main_bastion" {
  vpc_id        = aws_vpc.main.id
  peer_vpc_id   = aws_vpc.bastion.id
  auto_accept   = true

  tags = merge(
    local.tags,
    {
      Name = "${var.project}-main-bastion-peering"
    }
  )
}

# Add Route to Main VPC Route Table (pointing to Bastion

resource "aws_route" "main_to_bastion" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.cidr_bastion_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_bastion.id
}

#  Add Route to Bastion VPC Route Table (pointing to Main)

resource "aws_route" "bastion_to_main" {
  route_table_id         = aws_route_table.bastion_public.id
  destination_cidr_block = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main_bastion.id
}



# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.tags,
    {
      Name = "vpc-flow-logs-role"
    }
  )
}

# IAM Policy for VPC Flow Logs to write to CloudWatch Logs
resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}


# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "vpc_flow_logs_group" {
  name              = "/vpc/flow-logs"
  retention_in_days = 30

  tags = {
    Name = "VPC Flow Logs Group"
  }
}


# VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs_group.arn
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.vpc_flow_logs_role.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}