locals {
  tags = {
    project = var.project
  }
}


# Public NLB Security Group

resource "aws_security_group" "public_nlb_sg" {
  name        = var.public_nlb_sg_name
  description = "Allow HTTP/HTTPS traffic from internet"
  vpc_id      = var.vpc2_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
      local.tags,
      {
        Name = var.public_nlb_sg_name
      }
  )
}


# Private NGINX Security Group

resource "aws_security_group" "nginx_sg" {
  name        = var.nginx_sg_name
  description = "Allow HTTP/HTTPS traffic from Public NLB Security Group"
  vpc_id      = var.vpc2_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.public_nlb_sg.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Allow ICMP ping (Echo Request - type 8, any code)
  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] # Or ["0.0.0.0/0"] if from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_security_group.bastion_sg]

  tags = merge(
      local.tags,
      {
        Name = var.nginx_sg_name
      }
  )
}

# Private NLB Security Group

# resource "aws_security_group" "private_nlb_sg" {
#   name        = var.private_nlb_sg_name
#   description = "Allow app ports from NGINX SG"
#   vpc_id      = var.vpc2_id


#   ingress {
#     from_port       = 8080
#     to_port         = 8080
#     protocol        = "tcp"
#     security_groups = [aws_security_group.nginx_sg.id]
#   }

#   # ingress {
#   #   from_port   = 8080
#   #   to_port     = 8080
#   #   protocol    = "tcp"
#   #   cidr_blocks = ["10.0.10.0/24", "10.0.20.0/24"]
#   # }

#   # ingress {
#   #   from_port   = 80
#   #   to_port     = 80
#   #   protocol    = "tcp"
#   #   cidr_blocks = ["10.0.10.0/24", "10.0.20.0/24"]
#   # }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = merge(
#       local.tags,
#       {
#         Name = var.private_nlb_sg_name
#       }
#   )

# }


# ECS Task Security Group

resource "aws_security_group" "app_sg" {
  name        = var.app_sg_name
  description = "Allow app ports from NGINX SG"
  vpc_id      = var.vpc2_id


  # ingress {
  #   from_port       = 8080
  #   to_port         = 8080
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.nginx_sg.id]
  # }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.10.0/24", "10.0.20.0/24"]
  }

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["10.0.10.0/24", "10.0.20.0/24"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
      local.tags,
      {
        Name = var.app_sg_name
      }
  )

}

# Bastion Host Security Group

resource "aws_security_group" "bastion_sg" {
  name        = var.bastion_sg_name
  description = "Bastion host SG"
  vpc_id      = var.vpc1_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
      local.tags,
      {
        Name = var.bastion_sg_name
      }
  )

}


# Private DB Security Group

resource "aws_security_group" "database_sg" {
  name        = var.database_sg_name
  description = "Allow MongoDB from private and bastion SGs"
  vpc_id      = var.vpc2_id

  # Allow from private SG
  ingress {
    description     = "Allow from private SG"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  # Allow from bastion SG
  ingress {
    description     = "Allow from bastion SG"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_sg.id]
  }

  # Allow self-communication inside the database SG
  ingress {
    description     = "Allow internal database SG traffic"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
      local.tags,
      {
        Name = var.database_sg_name
      }
  )
}



